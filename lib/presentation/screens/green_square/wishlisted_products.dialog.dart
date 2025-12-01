import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/data/entities/wishlisted_product.dart';
import 'package:esg_mobile/presentation/screens/green_square/product_detail.screen.dart';
import 'package:esg_mobile/presentation/widgets/green_square/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class WishlistedProductsDialog extends StatefulWidget {
  const WishlistedProductsDialog({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<WishlistedProductsDialog> createState() =>
      _WishlistedProductsDialogState();
}

class _WishlistedProductsDialogState extends State<WishlistedProductsDialog> {
  bool isLoading = true;
  List<WishlistedProduct> wishlistedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => isLoading = true);
    final products = await ProductService.instance.fetchWishlistedProducts(
      widget.userId,
    );
    if (!mounted) return;
    setState(() {
      wishlistedProducts = products;
      isLoading = false;
    });
  }

  Future<void> _toggleWishlist(WishlistedProduct wishlistedProduct) async {
    await ProductService.instance.toggleWishlist(
      wishlistedProduct.product.product.code,
      widget.userId,
    );

    if (!mounted) return;
    setState(() {
      wishlistedProducts = wishlistedProducts
          .where(
            (item) =>
                item.product.product.code !=
                wishlistedProduct.product.product.code,
          )
          .toList();
    });
  }

  void _navigateToDetail(WishlistedProduct wishlistedProduct) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productWithDetails: wishlistedProduct.product,
            ),
            fullscreenDialog: true,
          ),
        )
        .then((_) {
          _loadWishlist();
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('찜한 상품'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : wishlistedProducts.isEmpty
            ? const Center(child: Text('찜한 상품이 없습니다.'))
            : MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: wishlistedProducts.length,
                itemBuilder: (context, index) {
                  final wishlistedProduct = wishlistedProducts[index];
                  return ProductCard(
                    productWithDetails: wishlistedProduct.product,
                    onWishlistToggle: () => _toggleWishlist(wishlistedProduct),
                    onTap: () => _navigateToDetail(wishlistedProduct),
                  );
                },
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '총 ${wishlistedProducts.length}개의 찜한 상품',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
