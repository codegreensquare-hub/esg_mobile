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

### 3. Base Discount

- **Computation**: `(Base Discount Rate / 100) × Product Original Price`
- **Type**: Computed value
- **Example**: If original price is 100,000₩ and base discount rate is 10%, base discount = 10,000₩

### 4. Selling Price Before Points

- **Computation**: `Product Original Price - Base Discount`
- **Type**: Computed value
- **Description**: Price after base discount but before additional point-based discounts

### 5. Platform Discount Rate

- **Source**: Directly from `platform_discount_rate` field
- **Type**: Database field
- **Description**: Percentage discount applied by the platform

### 6. Maximum Amount Discounted by Platform Discount Rate

- **Computation**: `Selling Price Before Points × (Platform Discount Rate / 100)`
- **Type**: Computed value
- **Description**: Maximum discount amount that can be applied using platform discount rate

### 7. Merchant Discount Rate

- **Source**: Directly from `vendor_discount_rate` field
- **Type**: Database field
- **Description**: Percentage discount applied by the vendor/merchant

### 8. Maximum Amount Discounted by Merchant Discount Rate

- **Computation**: `Selling Price Before Points × (Merchant Discount Rate / 100)`
- **Type**: Computed value
- **Description**: Maximum discount amount that can be applied using merchant discount rate

### 9. Maximum Discount Rate

- **Computation**: `Platform Discount Rate + Merchant Discount Rate`
- **Type**: Computed value
- **Description**: Combined discount rate from platform and merchant

### 10. Maximum Additional Discount via Points

- **Computation**: `Selling Price Before Points × (Maximum Discount Rate / 100)`
  - Where Maximum Discount Rate = Platform Discount Rate + Merchant Discount Rate
- **Type**: Computed value
- **Description**: Maximum amount that can be discounted using points (usable award points)
- **Note**: This represents the discount from platform and merchant rates applied to the price after base discount

### 11. Final Product Sale Price (after points) - Minimum payable price after points

- **Computation**: `Product Original Price - Base Discount - Maximum Additional Discount via Points`
- **Type**: Computed value
- **Description**: The minimum price a customer must pay after applying all available discounts and points

## Notes

- All monetary values are in Korean Won (₩)
- Discount rates are stored as percentages (e.g., 10 for 10%)
- Computations use floor rounding for point-based discounts to ensure integer values
- The final sale price represents the minimum amount payable when maximum points are used
- Platform discount rate has validation constraints based on contracted commission rates
- Combined platform and merchant discount rates cannot exceed 100%
- **Implementation Note**: The form calculations (create/edit) and table display use slightly different approaches. The form applies discounts sequentially (base first, then platform/merchant), while the table uses a combined discount calculation. The documentation above reflects the intended sequential logic.

## Code Reference

The computation logic is implemented in:

- `app/routes/vendor-admin/dashboard/product-management/create/create-page.tsx` (for form calculations)
- `app/routes/vendor-admin/dashboard/product-management/product-management-page.tsx` (for table display)
