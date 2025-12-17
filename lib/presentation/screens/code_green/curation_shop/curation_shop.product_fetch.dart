import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/enums/_enums.dart';
import 'package:esg_mobile/data/models/supabase/tables/product.dart';
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
  });

  final String tab;
  final String? subTab;

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
      itemBuilder: (context, index) =>
          _CurationProductCard(product: _products[index]),
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

class _CurationProductCard extends StatelessWidget {
  const _CurationProductCard({required this.product});

  final ProductWithOtherDetails product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
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

    return Card(
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
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: cs.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator.adaptive(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
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
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title ?? data.code,
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
    );
  }
}
