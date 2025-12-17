-- Creates a single-transaction checkout RPC that:
-- - creates payment (paid_at is NULL for now)
-- - creates order
-- - copies cart items -> order items
-- - copies cart item options -> order item options
-- - clears the cart
--
-- Call from client:
--   supabase.rpc('checkout_cart', params: { 'p_shipping_address': '<user_shipping_address.id>' })
-- p_shipping_address is REQUIRED and must belong to the authenticated user.

create or replace function public.checkout_cart(
  p_shipping_address uuid
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_payment_id uuid;
  v_order_id uuid;
  v_cart_item record;
  v_order_item_id uuid;
  v_uuid_regex text := '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
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

  -- Lock at least one VALID row to prevent concurrent modifications during checkout.
  -- (Older clients could have inserted empty/non-UUID product ids, which would
  --  otherwise crash checkout with "invalid input syntax for type uuid: \"\"".)
  perform 1
  from cart_item
  where customer = v_user_id
    and (product::text ~* v_uuid_regex)
  limit 1
  for update;

  if not found then
    raise exception 'Cart is empty';
  end if;

  insert into payment (payment_by, platform_id, paid_at)
  values (v_user_id, null, null)
  returning id into v_payment_id;

  insert into "order" (order_by, shipping_address, payment)
  values (v_user_id, p_shipping_address, v_payment_id)
  returning id into v_order_id;

  for v_cart_item in
    select id, product, quantity
    from cart_item
    where customer = v_user_id
      and (product::text ~* v_uuid_regex)
    order by created_at asc, id asc
    for update
  loop
    insert into order_item (product, quantity, "order")
    values ((v_cart_item.product::text)::uuid, v_cart_item.quantity, v_order_id)
    returning id into v_order_item_id;

    insert into order_item_option (order_item, option_parameter, option_value)
    select v_order_item_id, cio.option, cio.value
    from cart_item_option cio
    where cio.cart_item = v_cart_item.id
      and cio.option is not null
      and cio.value is not null;
  end loop;

  delete from cart_item_option
  where cart_item in (
    select id from cart_item where customer = v_user_id
  );

  delete from cart_item
  where customer = v_user_id;

  return v_order_id;
end;
$$;

revoke all on function public.checkout_cart(uuid) from public;
grant execute on function public.checkout_cart(uuid) to authenticated;
