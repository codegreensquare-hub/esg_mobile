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
