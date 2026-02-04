# Product Pricing Computation Documentation

This document explains how various pricing values are computed or retrieved for products in the ESG Admin system. The values are used in product creation, editing, and display tables.

## Data Sources

All pricing calculations are based on the following fields from the `product` table in the database:

- `regular_price`: The base price of the product (Product Original Price)
- `base_discount_rate`: Discount rate set by the merchant (Base Discount Rate)
- `platform_discount_rate`: Discount rate applied by the platform
- `vendor_discount_rate`: Discount rate applied by the vendor/merchant

## Pricing Values and Computation

### 1. Product Original Price (Base Price without discounts or deductions)

- **Source**: Directly from `regular_price` field
- **Type**: Database field
- **Description**: The initial price set for the product before any discounts

### 2. Base Discount Rate (Set by Merchant)

- **Source**: Directly from `base_discount_rate` field
- **Type**: Database field
- **Description**: Percentage discount applied by the merchant

### 3. Base Discount Amount

- **Computation**: `(Base Discount Rate / 100) × Product Original Price`
- **Type**: Computed value
- **Example**: If original price is 100,000₩ and base discount rate is 10%, base discount = 10,000₩

### 4. Selling Price Before Points

- **Computation**: `Product Original Price - Base Discount Amount`
- **Type**: Computed value
- **Description**: Price after base discount but before additional point-based discounts

### 5. Platform Discount Rate

- **Source**: Directly from `platform_discount_rate` field
- **Type**: Database field
- **Description**: Percentage discount applied by the platform

### 6. Vendor Discount Rate

- **Source**: Directly from `vendor_discount_rate` field
- **Type**: Database field
- **Description**: Percentage discount applied by the vendor/merchant

### 7. Maximum Discount Rate (Combined Platform + Vendor)

- **Computation**: `Platform Discount Rate + Vendor Discount Rate`
- **Type**: Computed value
- **Description**: Combined discount rate from platform and vendor that can be applied via points

### 8. Maximum Additional Discount via Points

- **Computation**: `Selling Price Before Points × (Maximum Discount Rate / 100) - Base Discount Amount`
- **Type**: Computed value
- **Description**: Maximum amount that can be discounted using points (usable award points)
- **Note**: This ensures points can only discount the additional amount beyond the base discount

### 9. Maximum Discount Benefit (Total Savings)

- **Computation**: `Base Discount Amount + Maximum Additional Discount via Points`
- **Type**: Computed value
- **Description**: Total maximum discount amount available (base discount + points discount)

### 10. Final Product Sale Price (Minimum payable price after all discounts)

- **Computation**: `Product Original Price - Maximum Discount Benefit`
- **Type**: Computed value
- **Description**: The minimum price a customer must pay after applying all available discounts and maximum points

## Implementation Notes

- **Combined Discount Logic**: Unlike sequential discounts, the admin system applies all discounts together to determine the final price. The base discount is applied first, then points can cover the remaining discountable amount.
- **Points Usage**: Users can use points up to the Maximum Discount Benefit amount, which includes both base discount and additional point-based discounts.
- **Validation**: Combined platform and vendor discount rates cannot exceed 100%. Platform discount rates have additional validation based on contracted commission rates.

## Code Reference

The computation logic is implemented in:

- Mobile app: `lib/core/utils/product_pricing.dart` (usableAwardPointsAmount, minimumPriceAmount functions)
- Admin system: `app/routes/vendor-admin/dashboard/product-management/create/create-page.tsx` (combined discount calculations)
- Admin system: `app/routes/vendor-admin/dashboard/product-management/product-management-page.tsx` (table display with combined discounts)

## Checkout Supabase function

Here lies the code for the supabase function that we use for RPC when checking out.

```sql
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

  for v_cart_item in
    select ci.id, ci.product, ci.quantity, p.regular_price
    from cart_item ci
    join product p on ci.product = p.id
    where ci.customer = v_user_id
    order by ci.created_at asc, ci.id asc
    for update
  loop
    insert into order_item (product, quantity, "order", price)
    values (v_cart_item.product, v_cart_item.quantity, v_order_id, v_cart_item.regular_price)
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
```
