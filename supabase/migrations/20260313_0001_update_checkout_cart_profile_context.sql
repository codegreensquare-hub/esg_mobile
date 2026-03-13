CREATE OR REPLACE FUNCTION public.checkout_cart(
  p_shipping_address uuid,
  p_award_points numeric DEFAULT 0,
  p_profile_used uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_payment_id uuid;
  v_order_id uuid;
  v_cart_item record;
  v_order_item_id uuid;
  v_transaction_id uuid;
  v_current_points numeric;
  v_effective_award_points numeric := 0;
  v_total_max_discount numeric := 0;
  v_item_max_discount numeric;
  v_allocated_points numeric;
  v_base_discount numeric;
  v_selling_price_before_points numeric;
  v_max_platform_discount numeric;
  v_max_merchant_discount numeric;
  v_platform_discount_used numeric;
  v_merchant_discount_used numeric;
  v_points_discount_by_greensquare numeric;
  v_points_discount_by_company numeric;
  v_user_department public."user".department%TYPE;
  v_user_sub_department public."user".sub_department%TYPE;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_shipping_address is null then
    raise exception 'Shipping address is required';
  end if;

  perform 1
  from user_shipping_address
  where id = p_shipping_address
    and address_by = v_user_id;

  if not found then
    raise exception 'Invalid shipping address';
  end if;

  select u.department, u.sub_department
    into v_user_department, v_user_sub_department
  from public."user" u
  where u.id = v_user_id;

  if not exists (
    select 1
    from cart_item ci
    where ci.customer = v_user_id
      and (
        (p_profile_used is null and ci.profile_used is null)
        or ci.profile_used = p_profile_used
      )
  ) then
    raise exception 'Cart is empty';
  end if;

  if coalesce(p_award_points, 0) > 0 then
    for v_cart_item in
      select
        ci.quantity,
        p.regular_price,
        p.base_discount_rate,
        p.platform_discount_rate,
        p.vendor_discount_rate
      from cart_item ci
      join product p on ci.product = p.id
      where ci.customer = v_user_id
        and (
          (p_profile_used is null and ci.profile_used is null)
          or ci.profile_used = p_profile_used
        )
    loop
      v_base_discount := v_cart_item.regular_price * coalesce(v_cart_item.base_discount_rate, 0) / 100;
      v_selling_price_before_points := v_cart_item.regular_price - v_base_discount;
      v_item_max_discount := (
        (v_selling_price_before_points * coalesce(v_cart_item.platform_discount_rate, 0) / 100)
        + (v_selling_price_before_points * coalesce(v_cart_item.vendor_discount_rate, 0) / 100)
      ) * v_cart_item.quantity;
      v_total_max_discount := v_total_max_discount + greatest(v_item_max_discount, 0);
    end loop;
  end if;

  v_effective_award_points := least(coalesce(p_award_points, 0), v_total_max_discount);

  if v_effective_award_points > 0 then
    select points into v_current_points
    from award_points
    where "user" = v_user_id;

    if v_current_points is null or v_current_points < v_effective_award_points then
      raise exception 'Insufficient award points';
    end if;
  end if;

  insert into payment (payment_by, platform_id, paid_at, profile_used)
  values (v_user_id, null, null, p_profile_used)
  returning id into v_payment_id;

  insert into "order" (
    order_by,
    shipping_address,
    payment,
    award_points_used,
    profile_used,
    department,
    sub_department
  )
  values (
    v_user_id,
    p_shipping_address,
    v_payment_id,
    v_effective_award_points,
    p_profile_used,
    v_user_department,
    v_user_sub_department
  )
  returning id into v_order_id;

  update payment
  set order_being_paid = v_order_id
  where id = v_payment_id;

  for v_cart_item in
    select
      ci.id,
      ci.product,
      ci.quantity,
      p.regular_price,
      p.base_discount_rate,
      p.platform_discount_rate,
      p.vendor_discount_rate
    from cart_item ci
    join product p on ci.product = p.id
    where ci.customer = v_user_id
      and (
        (p_profile_used is null and ci.profile_used is null)
        or ci.profile_used = p_profile_used
      )
    order by ci.created_at asc, ci.id asc
    for update
  loop
    v_points_discount_by_greensquare := 0;
    v_points_discount_by_company := 0;

    if v_effective_award_points > 0 and v_total_max_discount > 0 then
      v_base_discount := v_cart_item.regular_price * coalesce(v_cart_item.base_discount_rate, 0) / 100;
      v_selling_price_before_points := v_cart_item.regular_price - v_base_discount;
      v_max_platform_discount :=
        (v_selling_price_before_points * coalesce(v_cart_item.platform_discount_rate, 0) / 100)
        * v_cart_item.quantity;
      v_max_merchant_discount :=
        (v_selling_price_before_points * coalesce(v_cart_item.vendor_discount_rate, 0) / 100)
        * v_cart_item.quantity;

      v_item_max_discount := v_max_platform_discount + v_max_merchant_discount;
      v_allocated_points := (greatest(v_item_max_discount, 0) / v_total_max_discount) * v_effective_award_points;

      v_platform_discount_used := least(v_allocated_points, v_max_platform_discount);
      v_merchant_discount_used := least(v_allocated_points - v_platform_discount_used, v_max_merchant_discount);

      v_points_discount_by_greensquare := v_platform_discount_used;
      v_points_discount_by_company := v_merchant_discount_used;
    end if;

    insert into order_item (
      product,
      quantity,
      "order",
      price,
      points_discount_by_company,
      points_discount_by_greensquare
    )
    values (
      v_cart_item.product,
      v_cart_item.quantity,
      v_order_id,
      v_cart_item.regular_price,
      v_points_discount_by_company,
      v_points_discount_by_greensquare
    )
    returning id into v_order_item_id;

    insert into order_item_option (order_item, option_parameter, option_value)
    select v_order_item_id, cio.option, cio.value
    from cart_item_option cio
    where cio.cart_item = v_cart_item.id
      and cio.option is not null
      and cio.value is not null;
  end loop;

  if v_effective_award_points > 0 then
    insert into award_points_transaction (
      transaction_by,
      award_amount,
      previous_amount,
      new_amount,
      awarded_user
    )
    values (
      v_user_id,
      -v_effective_award_points,
      v_current_points,
      v_current_points - v_effective_award_points,
      v_user_id
    )
    returning id into v_transaction_id;

    update "order"
    set transaction_reference = v_transaction_id
    where id = v_order_id;
  end if;

  delete from cart_item_option
  where cart_item in (
    select ci.id
    from cart_item ci
    where ci.customer = v_user_id
      and (
        (p_profile_used is null and ci.profile_used is null)
        or ci.profile_used = p_profile_used
      )
  );

  delete from cart_item
  where customer = v_user_id
    and (
      (p_profile_used is null and profile_used is null)
      or profile_used = p_profile_used
    );

  return v_order_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.checkout_cart(
  p_shipping_address uuid,
  p_award_points numeric DEFAULT 0
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
begin
  return public.checkout_cart(p_shipping_address, p_award_points, null);
end;
$function$;

GRANT EXECUTE ON FUNCTION public.checkout_cart(uuid, numeric, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.checkout_cart(uuid, numeric) TO authenticated;