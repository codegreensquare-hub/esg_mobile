int usableAwardPointsAmount({
  required double regularPrice,
  required double totalDiscountRate,
}) {
  final amount = (regularPrice * totalDiscountRate / 100).floor();
  return amount < 0 ? 0 : amount;
}

int minimumPriceAmount({
  required double regularPrice,
  required double totalDiscountRate,
}) {
  final usableAward = usableAwardPointsAmount(
    regularPrice: regularPrice,
    totalDiscountRate: totalDiscountRate,
  );
  final amount = (regularPrice - usableAward).floor();
  return amount < 0 ? 0 : amount;
}
