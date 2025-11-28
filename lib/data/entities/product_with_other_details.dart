import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class ProductWithOtherDetails {
  final ProductRow product;
  final String? categoryName;
  final List<ProductImageRow> images;
  final bool isInWishlist;

  ProductWithOtherDetails({
    required this.product,
    this.categoryName,
    this.images = const [],
    this.isInWishlist = false,
  });
}
