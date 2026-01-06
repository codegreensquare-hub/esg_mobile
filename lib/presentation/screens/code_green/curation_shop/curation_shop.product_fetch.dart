import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/enums/_enums.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/code_green/product_detail_tab.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const int _defaultGridLimit = 12;

/// Fetches and renders Code Green curation products inside a responsive grid.
///
/// [tab] controls the high-level category (all/best/style/type) while the
/// optional [subTab] lets parent widgets drill deeper (e.g. tote, natural).
class CurationShopProductFetch extends StatefulWidget {
  const CurationShopProductFetch({
    super.key,
    required this.tab,
    this.subTab,
    this.onTapProduct,
  });

  final String tab;
  final String? subTab;
  final ValueChanged<ProductWithOtherDetails>? onTapProduct;

  @override
  State<CurationShopProductFetch> createState() =>
      _CurationShopProductFetchState();
}

class _CurationShopProductFetchState extends State<CurationShopProductFetch> {
  List<ProductWithOtherDetails> _products = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void didUpdateWidget(CurationShopProductFetch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab || oldWidget.subTab != widget.subTab) {
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final filter = _resolveQueryConfig(widget.tab, widget.subTab);
      final results = await ProductService.instance.fetchProducts(
        vendor: VendorAdminType.lgs,
        style: filter.style,
        material: filter.material,
        orderByField: filter.orderByField,
        orderAscending: filter.orderAscending,
        limit: filter.limit,
      );

      if (!mounted) return;
      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Error fetching curation products: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load products. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(_error!),
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No products found.'),
        ),
      );
    }

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      crossAxisCount: _getCrossAxisCount(context),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: _products.length,
      itemBuilder: (context, index) => _CurationProductCard(
        product: _products[index],
        onTap: widget.onTapProduct,
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1280) return 4;
    if (width >= 992) return 3;
    if (width >= 600) return 2;
    return 2;
  }
}

class _CurationQueryConfig {
  const _CurationQueryConfig({
    this.style,
    this.material,
  }) : orderByField = ProductRow.createdAtField,
       orderAscending = false,
       limit = _defaultGridLimit;

  final ProductStyle? style;
  final ProductMaterial? material;
  final String orderByField;
  final bool orderAscending;
  final int? limit;
}

_CurationQueryConfig _resolveQueryConfig(String tab, String? subTab) {
  final normalizedTab = tab.toLowerCase();
  switch (normalizedTab) {
    case 'best':
      return const _CurationQueryConfig();
    case 'style':
      return _CurationQueryConfig(style: _styleFromSlug(subTab));
    case 'type':
      return _CurationQueryConfig(material: _materialFromSlug(subTab));
    default:
      return const _CurationQueryConfig();
  }
}

ProductStyle? _styleFromSlug(String? slug) {
  final normalized = slug?.toLowerCase();
  if (normalized == null) {
    return null;
  }

  final matches = ProductStyle.values
      .where((style) => style.name == normalized)
      .toList(growable: false);
  return matches.isEmpty ? null : matches.first;
}

ProductMaterial? _materialFromSlug(String? slug) {
  final normalized = slug?.toLowerCase();
  if (normalized == null) {
    return null;
  }

  if (normalized == 'natural') {
    return ProductMaterial.nature_oriented;
  }

  final matches = ProductMaterial.values
      .where((material) => material.name == normalized)
      .toList(growable: false);
  return matches.isEmpty ? null : matches.first;
}

class _CurationProductCard extends StatefulWidget {
  const _CurationProductCard({required this.product, this.onTap});

  final ProductWithOtherDetails product;
  final ValueChanged<ProductWithOtherDetails>? onTap;

  @override
  State<_CurationProductCard> createState() => _CurationProductCardState();
}

class _CurationProductCardState extends State<_CurationProductCard> {
  List<ProductOptionColorRow> _colorValues = const [];
  String? _selectedImageUrl;
  String? _selectedColorHex;
  final Set<String> _preloadedImageUrls = <String>{};

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  @override
  void didUpdateWidget(covariant _CurationProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.product.id != widget.product.product.id) {
      _colorValues = const [];
      _selectedImageUrl = null;
      _selectedColorHex = null;
      _loadColors();
    }
  }

  Future<void> _loadColors() async {
    final pid = widget.product.product.id.trim();
    if (pid.isEmpty) {
      return;
    }

    final colors = await CartService.instance.fetchColorOptionValues(
      productId: pid,
    );
    if (!mounted) return;

    setState(() => _colorValues = colors);

    final data = widget.product.product;
    final baseImageUrl =
        data.mainImageBucket != null && data.mainImageFileName != null
        ? getImageLink(
            data.mainImageBucket!,
            data.mainImageFileName!,
            folderPath: data.mainImageFolderPath,
          )
        : null;

    final variantUrls = colors
        .map(
          (row) =>
              row.coloredProductBucket != null &&
                  row.coloredProductFileName != null
              ? getImageLink(
                  row.coloredProductBucket!,
                  row.coloredProductFileName!,
                  folderPath: row.coloredProductFolderPath,
                )
              : null,
        )
        .whereType<String>()
        .toList(growable: false);

    final urlsToPreload = <String?>[baseImageUrl, ...variantUrls]
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toSet()
        .difference(_preloadedImageUrls);

    if (urlsToPreload.isEmpty) return;
    _preloadedImageUrls.addAll(urlsToPreload);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.wait(
        urlsToPreload
            .map((url) => precacheImage(NetworkImage(url), context))
            .toList(growable: false),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final product = widget.product;
    final data = product.product;
    final price = data.regularPrice;
    final imageUrl =
        data.mainImageBucket != null && data.mainImageFileName != null
        ? getImageLink(
            data.mainImageBucket!,
            data.mainImageFileName!,
            folderPath: data.mainImageFolderPath,
          )
        : null;

    final resolvedImageUrl = _selectedImageUrl ?? imageUrl;

    return InkWell(
      onTap: () {
        final handler = widget.onTap;
        if (handler != null) {
          handler(product);
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CodeGreenProductDetailTabScreen(
              productWithDetails: product,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        color: cs.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  resolvedImageUrl != null
                      ? Image.network(
                          resolvedImageUrl,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: cs.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator.adaptive(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: cs.surfaceContainerHighest,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_not_supported),
                              ),
                        )
                      : Container(
                          color: cs.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image),
                        ),
                  if (_colorValues.isNotEmpty)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _colorValues
                              .where(
                                (row) => (row.value ?? '').trim().length == 6,
                              )
                              .map((row) {
                                final hex = (row.value ?? '').trim();
                                final isSelected =
                                    _selectedColorHex?.toLowerCase() ==
                                    hex.toLowerCase();

                                final color = Color(
                                  int.parse('FF$hex', radix: 16),
                                );

                                return InkWell(
                                  onTap: () {
                                    final bucket = row.coloredProductBucket;
                                    final fileName = row.coloredProductFileName;
                                    final folderPath =
                                        row.coloredProductFolderPath;

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
                                );
                              })
                              .toList(growable: false),
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
                    (data.title ?? '').isNotEmpty ? data.title! : 'Product',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.categoryName != null &&
                      product.categoryName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.categoryName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '[${product.seller.username ?? 'Unknown Seller'}]',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price != null ? formatKRW(price) : 'Price on request',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
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
