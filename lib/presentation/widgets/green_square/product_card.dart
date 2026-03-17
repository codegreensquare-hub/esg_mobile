import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
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
  final ValueChanged<bool>? onWishlistToggle;
  final VoidCallback? onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  List<ProductOptionColorRow> _colorValues = const [];
  String? _selectedImageUrl;
  String? _selectedColorHex;
  bool _isHeartHovered = false;
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _isInWishlist = widget.productWithDetails.isInWishlist;
    _loadColors();
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
    _isInWishlist = widget.productWithDetails.isInWishlist;
  }

  Future<void> _loadColors() async {
    final pid = widget.productWithDetails.product.id;
    final colors = await CartService.instance.fetchColorOptionValues(
      productId: pid,
    );
    if (!mounted) return;
    setState(() => _colorValues = colors);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final productWithDetails = widget.productWithDetails;
    final product = productWithDetails.product;
    final double? regularPrice = product.regularPrice;
    final baseDiscountRate = product.baseDiscountRate ?? 0.0;
    final platformDiscountRate = product.platformDiscountRate ?? 0.0;
    final vendorDiscountRate = product.vendorDiscountRate ?? 0.0;
    final totalDiscountRate =
        baseDiscountRate + platformDiscountRate + vendorDiscountRate;
    final int? discountedPrice = regularPrice == null
        ? null
        : minimumPriceAmount(
            regularPrice: regularPrice,
            baseDiscountRate: baseDiscountRate,
            platformDiscountRate: platformDiscountRate,
            vendorDiscountRate: vendorDiscountRate,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cellHeight = constraints.maxHeight;
            final imageSize = w;
            final textAreaHeight = (cellHeight - imageSize)
                .clamp(0.0, double.infinity)
                .toDouble();
            return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with Heart Button - fixed square size
                SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Stack(
                    children: [
                      // Image with Hero
                      Positioned.fill(
                        child: Hero(
                          tag: 'green-square-product-image-${product.id}',
                          child: resolvedImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: resolvedImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: cs.surfaceContainerHighest,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
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
                      Positioned(
                        top: 8,
                        right: 8,
                        child: MouseRegion(
                          onEnter: (_) =>
                              setState(() => _isHeartHovered = true),
                          onExit: (_) =>
                              setState(() => _isHeartHovered = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isHeartHovered
                                  ? cs.outline.withValues(alpha: 0.8)
                                  : cs.outline.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              visualDensity: VisualDensity(
                                horizontal: -3,
                                vertical: -3,
                              ),
                              icon: Icon(
                                _isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isInWishlist ? Colors.red : cs.surface,
                              ),
                              onPressed: () {
                                widget.onWishlistToggle?.call(_isInWishlist);
                                setState(() => _isInWishlist = !_isInWishlist);
                              },
                              iconSize: 20,
                              padding: EdgeInsets.all(0),
                            ),
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
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: Material(
                                          color: cs.surface.withValues(
                                            alpha: 0.75,
                                          ),
                                          shape: const StadiumBorder(),
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            onTap: () {
                                              final bucket =
                                                  valueRow.coloredProductBucket;
                                              final fileName = valueRow
                                                  .coloredProductFileName;
                                              final folderPath = valueRow
                                                  .coloredProductFolderPath;

                                              final nextUrl =
                                                  bucket != null &&
                                                      fileName != null
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
                SizedBox(
                  height: textAreaHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                                  productWithDetails
                                      .seller
                                      .username!
                                      .isNotEmpty)
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
                        const SizedBox(height: 4),
                        if (product.description != null &&
                            product.description!.isNotEmpty)
                          Expanded(
                            child: Text(
                              product.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Spacer(),
                        Text(
                          formatKRW(regularPrice ?? 0),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (discountPercentage != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '친환경 소비자라면, $discountPercentage%↓',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
