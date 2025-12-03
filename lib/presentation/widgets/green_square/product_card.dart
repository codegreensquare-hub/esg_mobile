import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.productWithDetails,
    this.onWishlistToggle,
    this.onTap,
  });

  final ProductWithOtherDetails productWithDetails;
  final VoidCallback? onWishlistToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final product = productWithDetails.product;
    final double? regularPrice = product.regularPrice;
    final double? discountedPrice = product.minimumPriceMinusAwardPoints;
    final hasDiscount =
        regularPrice != null &&
        discountedPrice != null &&
        regularPrice > 0 &&
        discountedPrice < regularPrice;
    final int? discountPercentage = hasDiscount
        ? (((regularPrice - discountedPrice) / regularPrice) * 100).round()
        : null;
    final imageUrl =
        product.mainImageBucket != null && product.mainImageFileName != null
        ? getImageLink(
            product.mainImageBucket!,
            product.mainImageFileName!,
            folderPath: product.mainImageFolderPath,
          )
        : null;

    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 0.1,
        color: cs.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Heart Button
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  // Image with Hero
                  Positioned.fill(
                    child: Hero(
                      tag: 'green-square-product-image-${product.code}',
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: cs.surfaceContainerHighest,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                            )
                          : Container(
                              color: cs.surfaceContainerHighest,
                              child: const Icon(Icons.image),
                            ),
                    ),
                  ),
                  // Heart Button
                  if (onWishlistToggle != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.outline.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          visualDensity: VisualDensity(
                            horizontal: -3,
                            vertical: -3,
                          ),
                          icon: Icon(
                            productWithDetails.isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: productWithDetails.isInWishlist
                                ? Colors.red
                                : cs.surface,
                          ),
                          onPressed: onWishlistToggle,
                          iconSize: 20,
                          padding: EdgeInsets.all(0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title ?? product.code,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        if (productWithDetails.seller.username != null &&
                            productWithDetails.seller.username!.isNotEmpty)
                          TextSpan(
                            text:
                                "[${productWithDetails.seller.username ?? 'Unknown Seller'}] ",
                          ),
                        TextSpan(
                          text: productWithDetails.product.name ?? '',
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    Text(
                      product.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    formatKRW(regularPrice ?? 0),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (discountPercentage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '친환경 소비자라면, $discountPercentage%↓',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatKRW(discountedPrice!),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
