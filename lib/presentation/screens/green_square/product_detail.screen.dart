import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/enums/product_sale_status.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productWithDetails,
  });

  final ProductWithOtherDetails productWithDetails;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductWithOtherDetails productWithDetails;
  bool isInWishlist = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    productWithDetails = widget.productWithDetails;
    userId = Supabase.instance.client.auth.currentUser?.id;
    isInWishlist = productWithDetails.isInWishlist;
  }

  Future<void> _toggleWishlist() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      await ProductService.instance.toggleWishlist(
        productWithDetails.product.code,
        userId!,
      );

      setState(() {
        isInWishlist = !isInWishlist;
        productWithDetails = ProductWithOtherDetails(
          product: productWithDetails.product,
          categoryName: productWithDetails.categoryName,
          images: productWithDetails.images,
          isInWishlist: isInWishlist,
        );
      });
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('찜하기 처리 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final product = productWithDetails.product;
    final imageUrl =
        product.mainImageBucket != null && product.mainImageFileName != null
        ? getImageLink(
            product.mainImageBucket!,
            product.mainImageFileName!,
            folderPath: product.mainImageFolderPath,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.code),
        actions: [
          if (userId != null)
            IconButton(
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: isInWishlist ? Colors.red : cs.onSurface,
              ),
              onPressed: _toggleWishlist,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            AspectRatio(
              aspectRatio: 1,
              child: Hero(
                tag: 'product-image-${product.code}',
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: cs.surfaceContainerHighest,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 64,
                          ),
                        ),
                      )
                    : Container(
                        color: cs.surfaceContainerHighest,
                        child: const Icon(
                          Icons.image,
                          size: 64,
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Code
                  Text(
                    product.code,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category
                  if (productWithDetails.categoryName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        productWithDetails.categoryName!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Price
                  Text(
                    '${product.salesPrice ?? product.regularPrice ?? 0} P',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.salesPrice != null &&
                      product.regularPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${product.regularPrice} P',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Description
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    Text(
                      '상품 설명',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stock Information
                  Row(
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '재고: ${product.stockQuantity.toInt()}개',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sale Status
                  Row(
                    children: [
                      Icon(
                        product.saleStatus == ProductSaleStatus.on_sale
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 20,
                        color: product.saleStatus == ProductSaleStatus.on_sale
                            ? Colors.green
                            : cs.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.saleStatus == ProductSaleStatus.on_sale
                            ? '판매 중'
                            : '판매 중지',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: product.saleStatus == ProductSaleStatus.on_sale
                              ? Colors.green
                              : cs.error,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement purchase functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('구매 기능은 곧 추가됩니다.')),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('구매하기'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
