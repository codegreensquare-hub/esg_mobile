import 'package:flutter/material.dart';

class ProductActionButtonsBar extends StatelessWidget {
  const ProductActionButtonsBar({
    super.key,
    required this.isAddingToCart,
    required this.onAddToCart,
    required this.onPurchase,
  });

  final bool isAddingToCart;
  final VoidCallback? onAddToCart;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isAddingToCart ? null : onAddToCart,
            icon: isAddingToCart
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_shopping_cart),
            label: Text(isAddingToCart ? '담는 중...' : '장바구니 담기'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPurchase,
            icon: const Icon(Icons.shopping_cart),
            label: const Text('구매하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
