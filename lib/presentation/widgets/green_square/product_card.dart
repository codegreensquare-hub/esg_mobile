import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/settings.service.dart';
import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/core/utils/product_pricing.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
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
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  List<ProductOptionColorRow> _colorValues = const [];
  String? _selectedImageUrl;
  String? _selectedColorHex;
  double _baseDiscountRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadColors();
    _loadBaseDiscountRate();
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productWithDetails.product.id !=
        widget.productWithDetails.product.id) {
      _colorValues = const [];
      _selectedImageUrl = null;
      _selectedColorHex = null;
      _loadColors();
    }
  }

  Future<void> _loadColors() async {
    final pid = widget.productWithDetails.product.id;
    final colors = await CartService.instance.fetchColorOptionValues(
      productId: pid,
    );
    if (!mounted) return;
    setState(() => _colorValues = colors);
  }

  Future<void> _loadBaseDiscountRate() async {
    final rate = await SettingsService.instance.getBaseDiscountRate();
    if (!mounted) return;
    setState(() => _baseDiscountRate = rate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final productWithDetails = widget.productWithDetails;
    final product = productWithDetails.product;
    final double? regularPrice = product.regularPrice;
    final double totalDiscountRate =
        _baseDiscountRate + product.additionalDiscountRate;
    final int? discountedPrice = regularPrice == null
        ? null
        : minimumPriceAmount(
            regularPrice: regularPrice,
            totalDiscountRate: totalDiscountRate,
          );
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

    final resolvedImageUrl = _selectedImageUrl ?? imageUrl;

    return InkWell(
      onTap: widget.onTap,
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
                      tag: 'green-square-product-image-${product.id}',
                      child: resolvedImageUrl != null
                          ? Image.network(
                              resolvedImageUrl,
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
                  if (widget.onWishlistToggle != null)
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
                          onPressed: widget.onWishlistToggle,
                          iconSize: 20,
                          padding: EdgeInsets.all(0),
                        ),
                      ),
                    ),

                  if (_colorValues.isNotEmpty)
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _colorValues
                                .map((valueRow) {
                                  final hex = (valueRow.value ?? '').trim();
                                  final isSelected =
                                      _selectedColorHex?.toLowerCase() ==
                                      hex.toLowerCase();

                                  final color = Color(
                                    int.parse('FF$hex', radix: 16),
                                  );

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Material(
                                      color: cs.surface.withValues(alpha: 0.75),
                                      shape: const StadiumBorder(),
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: () {
                                          final bucket =
                                              valueRow.coloredProductBucket;
                                          final fileName =
                                              valueRow.coloredProductFileName;
                                          final folderPath =
                                              valueRow.coloredProductFolderPath;

                                          final nextUrl =
                                              bucket != null && fileName != null
                                              ? getImageLink(
                                                  bucket,
                                                  fileName,
                                                  folderPath: folderPath,
                                                )
                                              : null;

                                          setState(() {
                                            _selectedColorHex = hex;
                                            _selectedImageUrl = nextUrl;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color,
                                              border: Border.all(
                                                color: isSelected
                                                    ? cs.primary
                                                    : cs.outlineVariant,
                                                width: isSelected ? 2 : 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(growable: false),
                          ),
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
                    product.title ?? '제품명 없음',
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
                      maxLines: 4,
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
