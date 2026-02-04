int usableAwardPointsAmount({
  required double regularPrice,
  required double baseDiscountRate,
  required double platformDiscountRate,
  required double vendorDiscountRate,
}) {
  // Base Discount = Original Price * Base Discount Rate
  final baseDiscount = (regularPrice * baseDiscountRate / 100).floor();

  // Selling Price Before Points = Original Price - Base Discount
  final sellingPriceBeforePoints = regularPrice - baseDiscount;

  // Maximum Discount Rate = Platform Discount Rate + Vendor Discount Rate
  final maxDiscountRate = platformDiscountRate + vendorDiscountRate;

  // Combined Discount = Selling Price Before Points * Maximum Discount Rate
  final combinedDiscount = (sellingPriceBeforePoints * maxDiscountRate / 100)
      .floor();

  // Maximum Additional Discount via Points = Combined Discount - Base Discount
  final amount = combinedDiscount - baseDiscount;
  return amount < 0 ? 0 : amount;
}

int minimumPriceAmount({
  required double regularPrice,
  required double baseDiscountRate,
  required double platformDiscountRate,
  required double vendorDiscountRate,
}) {
  // Base Discount = Original Price * Base Discount Rate
  final baseDiscount = (regularPrice * baseDiscountRate / 100).floor();

  // Selling Price Before Points = Original Price - Base Discount
  final sellingPriceBeforePoints = regularPrice - baseDiscount;

  // Maximum Discount Rate = Platform Discount Rate + Vendor Discount Rate
  final maxDiscountRate = platformDiscountRate + vendorDiscountRate;

  // Combined Discount = Selling Price Before Points * Maximum Discount Rate
  final combinedDiscount = (sellingPriceBeforePoints * maxDiscountRate / 100)
      .floor();

  // Maximum Additional Discount via Points = Combined Discount - Base Discount
  final maxPointsDiscount = combinedDiscount - baseDiscount;

  // Final Price = Original Price - Base Discount - Maximum Additional Discount via Points
  final amount = (regularPrice - baseDiscount - maxPointsDiscount).floor();
  return amount < 0 ? 0 : amount;
}
