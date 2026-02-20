-- Update checkout_cart function to handle award points distribution
CREATE OR REPLACE FUNCTION public.checkout_cart(p_shipping_address uuid, p_award_points numeric DEFAULT 0)
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
  v_total_max_discount numeric := 0;
  v_item_max_discount numeric;
  v_allocated_points numeric;
  v_base_discount numeric;
  v_selling_price_before_points numeric;
  v_max_platform_discount numeric;
  v_max_merchant_discount numeric;
  v_base_discount_used numeric;
  v_platform_discount_used numeric;
  v_merchant_discount_used numeric;
  v_points_discount_by_greensquare numeric;
  v_points_discount_by_company numeric;
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

  -- Check award points if provided
  if p_award_points > 0 then
    select points into v_current_points
    from award_points
    where "user" = v_user_id;

    if v_current_points is null or v_current_points < p_award_points then
      raise exception 'Insufficient award points';
    end if;
  end if;

  insert into payment (payment_by, platform_id, paid_at)
  values (v_user_id, null, null)
  returning id into v_payment_id;

  insert into "order" (order_by, shipping_address, payment, award_points_used)
  values (v_user_id, p_shipping_address, v_payment_id, coalesce(p_award_points, 0))
  returning id into v_order_id;

  -- Check if cart is empty
  if not exists (select 1 from cart_item where customer = v_user_id) then
    raise exception 'Cart is empty';
  end if;

  -- Calculate total maximum discountable amount for point distribution
  if p_award_points > 0 then
    for v_cart_item in
      select p.regular_price, p.base_discount_rate, p.platform_discount_rate, p.vendor_discount_rate
      from cart_item ci
      join product p on ci.product = p.id
      where ci.customer = v_user_id
    loop
      v_base_discount := v_cart_item.regular_price * coalesce(v_cart_item.base_discount_rate, 0) / 100;
      v_selling_price_before_points := v_cart_item.regular_price - v_base_discount;
      v_item_max_discount := v_selling_price_before_points * (coalesce(v_cart_item.platform_discount_rate, 0) + coalesce(v_cart_item.vendor_discount_rate, 0)) / 100 - v_base_discount;
      v_total_max_discount := v_total_max_discount + greatest(v_item_max_discount, 0);
    end loop;
  end if;

  for v_cart_item in
    select ci.id, ci.product, ci.quantity, p.regular_price, p.base_discount_rate, p.platform_discount_rate, p.vendor_discount_rate
    from cart_item ci
    join product p on ci.product = p.id
    where ci.customer = v_user_id
    order by ci.created_at asc, ci.id asc
    for update
  loop
    -- Calculate point distribution for this item
    v_points_discount_by_greensquare := 0;
    v_points_discount_by_company := 0;

    if p_award_points > 0 and v_total_max_discount > 0 then
      v_base_discount := v_cart_item.regular_price * coalesce(v_cart_item.base_discount_rate, 0) / 100;
      v_selling_price_before_points := v_cart_item.regular_price - v_base_discount;
      v_max_platform_discount := v_selling_price_before_points * coalesce(v_cart_item.platform_discount_rate, 0) / 100;
      v_max_merchant_discount := v_selling_price_before_points * coalesce(v_cart_item.vendor_discount_rate, 0) / 100;

      v_item_max_discount := v_selling_price_before_points * (coalesce(v_cart_item.platform_discount_rate, 0) + coalesce(v_cart_item.vendor_discount_rate, 0)) / 100;
      v_allocated_points := (greatest(v_item_max_discount, 0) / v_total_max_discount) * p_award_points;

      -- Distribute allocated points according to Excel logic
      v_base_discount_used := least(v_allocated_points, v_base_discount);
      v_platform_discount_used := least(v_allocated_points - v_base_discount_used, v_max_platform_discount);
      v_merchant_discount_used := least(v_allocated_points - v_platform_discount_used, v_max_merchant_discount);

      v_points_discount_by_greensquare := v_platform_discount_used;
      v_points_discount_by_company := v_merchant_discount_used;
    end if;

    insert into order_item (product, quantity, "order", price, points_discount_by_company, points_discount_by_greensquare)
    values (v_cart_item.product, v_cart_item.quantity, v_order_id, v_cart_item.regular_price, v_points_discount_by_company, v_points_discount_by_greensquare)
    returning id into v_order_item_id;

    insert into order_item_option (order_item, option_parameter, option_value)
    select v_order_item_id, cio.option, cio.value
    from cart_item_option cio
    where cio.cart_item = v_cart_item.id
      and cio.option is not null
      and cio.value is not null;
  end loop;

  -- Deduct award points if used
  if p_award_points > 0 then
    insert into award_points_transaction (transaction_by, award_amount, previous_amount, new_amount, awarded_user)
    values (v_user_id, -p_award_points, v_current_points, v_current_points - p_award_points, v_user_id)
    returning id into v_transaction_id;

    update "order" set transaction_reference = v_transaction_id where id = v_order_id;
  end if;

  delete from cart_item_option
  where cart_item in (
    select id from cart_item where customer = v_user_id
  );

  delete from cart_item
  where customer = v_user_id;

  return v_order_id;
end;
$function$

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.checkout_cart(uuid, numeric) TO authenticated;

-- Patch existing order_items to set price from product
UPDATE order_item
SET price = product.regular_price
FROM product
WHERE order_item.product = product.id
  AND order_item.price IS NULL;