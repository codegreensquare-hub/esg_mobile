import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/constants/navigation.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/settings.service.dart';
import 'package:esg_mobile/core/utils/product_pricing.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/code_green/widgets/lookbook_product_marker.widget.dart';
import 'package:esg_mobile/presentation/screens/code_green/product_detail_tab.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef LookbookPlacement = ({String id, String productId, double x, double y});
typedef ProductInfo = ({
  String name,
  String? thumbnailUrl,
  ProductWithOtherDetails? product,
});

typedef ProductsById = Map<String, ProductInfo>;

typedef _LookbookEntryData = ({
  String id,
  String imageUrl,
  List<LookbookPlacement> placements,
});

Rect _fittedRectForContain({
  required Size containerSize,
  required Size imageSize,
}) {
  final fittedSizes = applyBoxFit(BoxFit.contain, imageSize, containerSize);
  final fittedWidth = fittedSizes.destination.width;
  final fittedHeight = fittedSizes.destination.height;

  final dx = (containerSize.width - fittedWidth) / 2;
  final dy = (containerSize.height - fittedHeight) / 2;

  return Rect.fromLTWH(dx, dy, fittedWidth, fittedHeight);
}

Offset _pixelFromNormalized({
  required Rect fittedRect,
  required double x,
  required double y,
}) {
  return Offset(
    fittedRect.left + x * fittedRect.width,
    fittedRect.top + y * fittedRect.height,
  );
}

class LookbookEntryViewerTab extends StatefulWidget {
  static const tab = lookbookEntryViewerTabId;

  const LookbookEntryViewerTab({
    required this.lookbookId,
    required this.lookbookTitle,
    this.onOpenProduct,
    super.key,
  });

  final String? lookbookId;
  final String? lookbookTitle;
  final ValueChanged<ProductWithOtherDetails>? onOpenProduct;

  @override
  State<LookbookEntryViewerTab> createState() => _LookbookEntryViewerTabState();
}

class _LookbookEntryViewerTabState extends State<LookbookEntryViewerTab> {
  final Map<String, Size> _intrinsicSizesByImageUrl = {};
  final Set<String> _failedIntrinsicSizeUrls = {};

  Future<void>? _loadFuture;

  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  List<_LookbookEntryData> _entries = const [];
  ProductsById _productsById = const {};
  double _baseDiscountRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFuture = _fetchAll();
    _loadBaseDiscountRate();
  }

  Future<void> _loadBaseDiscountRate() async {
    try {
      final rate = await SettingsService.instance.getBaseDiscountRate();
      if (!mounted) return;
      setState(() => _baseDiscountRate = rate);
    } catch (e) {
      debugPrint('Error loading base discount rate: $e');
    }
  }

  @override
  void didUpdateWidget(covariant LookbookEntryViewerTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.lookbookId != widget.lookbookId) {
      _detachImageListener();
      _intrinsicSizesByImageUrl.clear();
      _failedIntrinsicSizeUrls.clear();
      _entries = const [];
      _productsById = const {};
      _loadFuture = widget.lookbookId == null ? null : _fetchAll();
    }
  }

  @override
  void dispose() {
    _detachImageListener();
    super.dispose();
  }

  void _detachImageListener() {
    final stream = _imageStream;
    final listener = _imageStreamListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _imageStream = null;
    _imageStreamListener = null;
  }

  void _requestIntrinsicSizeFor(String imageUrl) {
    if (_intrinsicSizesByImageUrl.containsKey(imageUrl)) return;
    if (_failedIntrinsicSizeUrls.contains(imageUrl)) return;

    _detachImageListener();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_intrinsicSizesByImageUrl.containsKey(imageUrl)) return;
      if (_failedIntrinsicSizeUrls.contains(imageUrl)) return;
      _resolveIntrinsicImageSizeFor(imageUrl);
    });
  }

  void _resolveIntrinsicImageSizeFor(String imageUrl) {
    final provider = NetworkImage(imageUrl);
    final stream = provider.resolve(createLocalImageConfiguration(context));
    _imageStream = stream;

    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        final size = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );

        if (!mounted) return;
        setState(() {
          _intrinsicSizesByImageUrl[imageUrl] = size;
        });

        _detachImageListener();
      },
      onError: (error, stackTrace) {
        debugPrint('Failed to resolve image size: $error');

        if (!mounted) return;
        setState(() {
          _failedIntrinsicSizeUrls.add(imageUrl);
        });

        _detachImageListener();
      },
    );

    _imageStreamListener = listener;
    stream.addListener(listener);
  }

  Future<void> _fetchAll() async {
    final lookbookId = widget.lookbookId;
    if (lookbookId == null || lookbookId.trim().isEmpty) return;

    final client = Supabase.instance.client;

    final entryRows = await client
        .from(LookbookEntryTable().tableName)
        .select()
        .eq(LookbookEntryRow.lookbookField, lookbookId)
        .order(LookbookEntryRow.orderField, ascending: true);

    final entries = (entryRows as List)
        .whereType<Map<String, dynamic>>()
        .map((data) {
          try {
            return LookbookEntryRow.fromJson(data);
          } catch (e) {
            debugPrint('Error parsing lookbook_entry row: $e');
            return null;
          }
        })
        .whereType<LookbookEntryRow>()
        .where(
          (e) =>
              (e.bucket ?? '').trim().isNotEmpty &&
              (e.fileName ?? '').trim().isNotEmpty &&
              e.id.trim().isNotEmpty,
        )
        .toList(growable: false);

    final entryIds = entries.map((e) => e.id).toList(growable: false);

    final List<dynamic> productRows = entryIds.isEmpty
        ? const <dynamic>[]
        : (await client
                  .from(LookbookProductTable().tableName)
                  .select()
                  .inFilter(LookbookProductRow.lookbookEntryField, entryIds))
              as List;

    final lookbookProducts = productRows
        .whereType<Map<String, dynamic>>()
        .map((data) {
          try {
            return LookbookProductRow.fromJson(data);
          } catch (e) {
            debugPrint('Error parsing lookbook_product row: $e');
            return null;
          }
        })
        .whereType<LookbookProductRow>()
        .where(
          (p) =>
              (p.lookbookEntry ?? '').trim().isNotEmpty &&
              (p.product ?? '').trim().isNotEmpty &&
              p.x != null &&
              p.y != null,
        )
        .toList(growable: false);

    final placementsByEntryId = lookbookProducts.fold(
      <String, List<LookbookPlacement>>{},
      (acc, p) {
        final entryId = p.lookbookEntry!.trim();
        final placement = (
          id: p.id,
          productId: p.product!.trim(),
          x: (p.x!).clamp(0.0, 1.0),
          y: (p.y!).clamp(0.0, 1.0),
        );

        final existing = acc[entryId];
        acc[entryId] = existing == null
            ? [placement]
            : [...existing, placement];
        return acc;
      },
    );

    final productIds = lookbookProducts
        .map((p) => p.product)
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final userId = client.auth.currentUser?.id;
    final productsWithDetails = productIds.isEmpty
        ? const <ProductWithOtherDetails>[]
        : await ProductService.instance.fetchProductsByIds(
            productIds: productIds,
            userId: userId,
          );

    final productsById = Map<String, ProductInfo>.fromEntries(
      productsWithDetails.map((p) {
        final row = p.product;
        final id = row.id.trim();
        if (id.isEmpty) return null;

        final name = (row.title ?? row.name ?? '').trim();
        final bucket = row.mainImageBucket;
        final fileName = row.mainImageFileName;

        final thumbnailUrl =
            (bucket ?? '').trim().isNotEmpty &&
                (fileName ?? '').trim().isNotEmpty
            ? getImageLink(
                bucket!.trim(),
                fileName!.trim(),
                folderPath: (row.mainImageFolderPath ?? '').trim().isEmpty
                    ? null
                    : row.mainImageFolderPath!.trim(),
              )
            : null;

        return MapEntry(
          id,
          (
            name: name.isEmpty ? 'Product' : name,
            thumbnailUrl: thumbnailUrl,
            product: p,
          ),
        );
      }).whereType<MapEntry<String, ProductInfo>>(),
    );

    final entryData = entries
        .map((e) {
          final url = getImageLink(
            (e.bucket ?? '').trim(),
            (e.fileName ?? '').trim(),
            folderPath: (e.folderPath ?? '').trim().isEmpty
                ? null
                : e.folderPath!.trim(),
          );

          return (
            id: e.id,
            imageUrl: url,
            placements: (placementsByEntryId[e.id] ?? const []).toList(
              growable: false,
            ),
          );
        })
        .toList(growable: false);

    if (!mounted) return;
    setState(() {
      _entries = entryData;
      _productsById = productsById;
    });

    for (final entry in entryData) {
      _requestIntrinsicSizeFor(entry.imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.lookbookId == null || widget.lookbookId!.trim().isEmpty) {
      return Center(
        child: Text(
          'Select a lookbook',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load lookbook entries',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        if (_entries.isEmpty) {
          return Center(
            child: Text(
              'No entries',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final contentWidth = availableWidth > 800 ? 800.0 : availableWidth;

            return Container(
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerLowest,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if ((widget.lookbookTitle ?? '').trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 60, 16, 8),
                        child: Text(
                          widget.lookbookTitle!.trim().toUpperCase(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        final imageUrl = entry.imageUrl;
                        final imageSize = _intrinsicSizesByImageUrl[imageUrl];

                        if (imageSize == null) {
                          if (_failedIntrinsicSizeUrls.contains(imageUrl)) {
                            return SizedBox(
                              width: contentWidth,
                              height: 200,
                              child: Center(
                                child: Text(
                                  'Failed to load image',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }

                          _requestIntrinsicSizeFor(imageUrl);
                          return SizedBox(
                            width: contentWidth,
                            height: 200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final height =
                            contentWidth * (imageSize.height / imageSize.width);
                        final containerSize = Size(contentWidth, height);
                        final fittedRect = _fittedRectForContain(
                          containerSize: containerSize,
                          imageSize: imageSize,
                        );

                        const markerRadius = 6.0;
                        const markerHaloRadius = 16.0;

                        return SizedBox(
                          width: contentWidth,
                          height: height,
                          child: ExcludeSemantics(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    excludeFromSemantics: true,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          'Failed to load image',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                ...entry.placements.map((p) {
                                  final pos = _pixelFromNormalized(
                                    fittedRect: fittedRect,
                                    x: p.x,
                                    y: p.y,
                                  );
                                  final product = _productsById[p.productId];
                                  final openProduct = product?.product;

                                  final row = openProduct?.product;
                                  final regularPrice = row?.regularPrice;
                                  final additionalDiscountRate =
                                      row?.additionalDiscountRate ?? 0.0;
                                  final totalDiscountRate =
                                      _baseDiscountRate +
                                      additionalDiscountRate;
                                  final price = regularPrice == null
                                      ? null
                                      : minimumPriceAmount(
                                          regularPrice: regularPrice,
                                          totalDiscountRate: totalDiscountRate,
                                        );
                                  final priceText = price == null
                                      ? (regularPrice == null
                                            ? null
                                            : formatKRW(regularPrice))
                                      : formatKRW(price);
                                  final description = (row?.description ?? '')
                                      .trim();

                                  return Positioned(
                                    left: pos.dx - markerHaloRadius,
                                    top: pos.dy - markerHaloRadius,
                                    width: markerHaloRadius * 2,
                                    height: markerHaloRadius * 2,
                                    child: LookbookProductMarker(
                                      productName:
                                          product?.name ?? 'Unknown product',
                                      thumbnailUrl: product?.thumbnailUrl,
                                      priceText: priceText,
                                      description: description.isEmpty
                                          ? null
                                          : description,
                                      markerRadius: markerRadius,
                                      markerHaloRadius: markerHaloRadius,
                                      onOpenProduct: openProduct == null
                                          ? null
                                          : () => widget.onOpenProduct?.call(
                                              openProduct,
                                            ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Products grid
                    Builder(
                      builder: (context) {
                        final products = _productsById.values
                            .where((p) => p.product != null)
                            .map((p) => p.product!)
                            .toList(growable: false);
                        if (products.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                              child: Text(
                                'Products in this Lookbook',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            MasonryGridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              primary: false,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return LookbookProductCard(
                                  product: product,
                                  onTap: widget.onOpenProduct,
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class LookbookProductCard extends StatefulWidget {
  const LookbookProductCard({super.key, required this.product, this.onTap});

  final ProductWithOtherDetails product;
  final ValueChanged<ProductWithOtherDetails>? onTap;

  @override
  State<LookbookProductCard> createState() => _LookbookProductCardState();
}

class _LookbookProductCardState extends State<LookbookProductCard> {
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
  void didUpdateWidget(covariant LookbookProductCard oldWidget) {
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
