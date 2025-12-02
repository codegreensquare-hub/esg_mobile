import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class CartItemWithProduct {
  const CartItemWithProduct({
    required this.cartItem,
    required this.product,
    required this.options,
  });

  final CartItemRow cartItem;
  final ProductRow product;
  final List<CartItemOptionRow> options;

  double get unitPrice =>
      (product.salesPrice ?? product.regularPrice ?? 0).toDouble();

  double get totalPrice => unitPrice * cartItem.quantity;

  int get quantity => cartItem.quantity.round();
}
