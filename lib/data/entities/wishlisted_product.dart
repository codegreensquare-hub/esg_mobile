import 'package:esg_mobile/data/entities/product_with_other_details.dart';

class WishlistedProduct {
  const WishlistedProduct({
    required this.product,
    required this.createdAt,
  });

  final ProductWithOtherDetails product;
  final DateTime createdAt;

  WishlistedProduct copyWith({
    ProductWithOtherDetails? product,
    DateTime? createdAt,
  }) {
    return WishlistedProduct(
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
