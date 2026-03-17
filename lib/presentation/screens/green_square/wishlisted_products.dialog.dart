import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/data/entities/wishlisted_product.dart';
import 'package:esg_mobile/presentation/screens/green_square/product_detail.screen.dart';
import 'package:esg_mobile/presentation/widgets/green_square/product_card.dart';
import 'package:flutter/material.dart';

class WishlistedProductsDialog extends StatefulWidget {
  const WishlistedProductsDialog({
    super.key,
    required this.userId,
    this.onBadgeUpdate,
  });

  final String userId;
  final VoidCallback? onBadgeUpdate;

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

  Future<void> _toggleWishlist(
    WishlistedProduct wishlistedProduct,
    bool isInWishlist,
  ) async {
    if (isInWishlist) {
      await ProductService.instance.removeFromWishlist(
        wishlistedProduct.product.product.id,
        widget.userId,
      );
    } else {
      await ProductService.instance.addToWishlist(
        wishlistedProduct.product.product.id,
        widget.userId,
      );
    }

    if (!mounted) return;
    if (isInWishlist) {
      setState(() {
        wishlistedProducts = wishlistedProducts
            .where(
              (item) =>
                  item.product.product.id !=
                  wishlistedProduct.product.product.id,
            )
            .toList();
      });
    } else {
      // If adding, reload the list
      _loadWishlist();
    }
    widget.onBadgeUpdate?.call();
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
          widget.onBadgeUpdate?.call();
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistedProducts.isEmpty
          ? const Center(child: Text('찜한 상품이 없습니다.'))
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = switch (constraints.maxWidth) {
                  >= 1200 => 4,
                  >= 700 => 3,
                  _ => 2,
                };

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.48,
                      ),
                      itemCount: wishlistedProducts.length,
                      itemBuilder: (context, index) {
                        final wishlistedProduct = wishlistedProducts[index];
                        return ProductCard(
                          productWithDetails: wishlistedProduct.product,
                          onWishlistToggle: (isInWishlist) => _toggleWishlist(
                            wishlistedProduct,
                            isInWishlist,
                          ),
                          onTap: () => _navigateToDetail(wishlistedProduct),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 18, 8),
          child: Text(
            '총 ${wishlistedProducts.length}개의 찜한 상품',
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
