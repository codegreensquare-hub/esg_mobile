import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef LookbookPlacement = ({String id, String productId, double x, double y});
typedef ProductInfo = ({String name, String? thumbnailUrl});

typedef ProductsById = Map<String, ProductInfo>;

typedef _LookbookEntryData = ({
  String id,
  String imageUrl,
  List<LookbookPlacement> placements,
});

Rect fittedRectForContain({
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

Offset pixelFromNormalized({
  required Rect fittedRect,
  required double x,
  required double y,
}) {
  return Offset(
    fittedRect.left + x * fittedRect.width,
    fittedRect.top + y * fittedRect.height,
  );
}

class LookbookEntryViewerScreen extends StatefulWidget {
  const LookbookEntryViewerScreen({
    required this.lookbookId,
    required this.lookbookTitle,
    super.key,
  });

  final String lookbookId;
  final String lookbookTitle;

  @override
  State<LookbookEntryViewerScreen> createState() =>
      _LookbookEntryViewerScreenState();
}

class _LookbookEntryViewerScreenState extends State<LookbookEntryViewerScreen> {
  final PageController _pageController = PageController();
  late final Future<void> _loadFuture;

  final Map<String, Size> _intrinsicSizesByImageUrl = {};
  final Set<String> _failedIntrinsicSizeUrls = {};

  String? _currentImageUrl;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  List<_LookbookEntryData> _entries = const [];
  ProductsById _productsById = const {};

  @override
  void initState() {
    super.initState();
    _loadFuture = _fetchAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure we have a chance to resolve sizes once we have a context.
    final url = _currentImageUrl;
    if (url != null) {
      _requestIntrinsicSizeFor(url);
    }
  }

  @override
  void didUpdateWidget(covariant LookbookEntryViewerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.lookbookId != widget.lookbookId) {
      // This screen is intended to be created per lookbook.
      // If caller changes lookbookId in-place, rebuild state.
      _detachImageListener();
      _entries = const [];
      _productsById = const {};
      _intrinsicSizesByImageUrl.clear();
      _failedIntrinsicSizeUrls.clear();
      _currentImageUrl = null;
    }
  }

  @override
  void dispose() {
    _detachImageListener();
    _pageController.dispose();
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

    // Ensure we only listen to one image stream at a time.
    _detachImageListener();

    // Resolve after the current frame so context/config is stable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_intrinsicSizesByImageUrl.containsKey(imageUrl)) return;
      if (_failedIntrinsicSizeUrls.contains(imageUrl)) return;
      _resolveIntrinsicImageSizeFor(imageUrl);
    });
  }

  void _resolveIntrinsicImageSizeFor(String imageUrl) {
    final provider = NetworkImage(imageUrl);

    final stream = provider.resolve(
      createLocalImageConfiguration(context),
    );

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
    final client = Supabase.instance.client;

    final entryRows = await client
        .from(LookbookEntryTable().tableName)
        .select()
        .eq(LookbookEntryRow.lookbookField, widget.lookbookId)
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

    final List<dynamic> productsResponse = productIds.isEmpty
        ? const <dynamic>[]
        : (await client
                  .from(ProductTable().tableName)
                  .select(
                    '${ProductRow.idField}, '
                    '${ProductRow.nameField}, '
                    '${ProductRow.titleField}, '
                    '${ProductRow.mainImageBucketField}, '
                    '${ProductRow.mainImageFolderPathField}, '
                    '${ProductRow.mainImageFileNameField}',
                  )
                  .inFilter(ProductRow.idField, productIds))
              as List;

    final productsById = Map<String, ProductInfo>.fromEntries(
      productsResponse.whereType<Map<String, dynamic>>().map((data) {
        final row = ProductRow.fromJson(data);
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
          (name: name.isEmpty ? 'Product' : name, thumbnailUrl: thumbnailUrl),
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
      _currentImageUrl = entryData.isNotEmpty ? entryData.first.imageUrl : null;
    });

    final firstUrl = _currentImageUrl;
    if (firstUrl != null) {
      _requestIntrinsicSizeFor(firstUrl);
    }
  }

  Future<void> _showMarkerSheet({
    required String entryId,
    required LookbookPlacement placement,
  }) async {
    final theme = Theme.of(context);
    final product = _productsById[placement.productId];

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final cs = theme.colorScheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: ClipRect(
                        child: product?.thumbnailUrl != null
                            ? Image.network(
                                product!.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: cs.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: cs.surfaceContainerHighest,
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product?.name ?? 'Unknown product',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lookbookTitle),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: FutureBuilder<void>(
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

          return PageView.builder(
            controller: _pageController,
            itemCount: _entries.length,
            onPageChanged: (index) {
              final url = _entries[index].imageUrl;
              setState(() {
                _currentImageUrl = url;
              });

              _requestIntrinsicSizeFor(url);
            },
            itemBuilder: (context, index) {
              final entry = _entries[index];
              final imageUrl = entry.imageUrl;
              final imageSize = _intrinsicSizesByImageUrl[imageUrl];

              if (imageSize == null) {
                if (_failedIntrinsicSizeUrls.contains(imageUrl)) {
                  return Center(
                    child: Text(
                      'Failed to load image',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                _requestIntrinsicSizeFor(imageUrl);

                // Ensure this entry becomes the current image to resolve.
                if (_currentImageUrl != imageUrl) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      _currentImageUrl = imageUrl;
                    });
                  });
                }

                return const Center(child: CircularProgressIndicator());
              }

              const markerRadius = 6.0;
              const markerHaloRadius = 16.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        if (width <= 0) return const SizedBox.shrink();

                        final height =
                            width * (imageSize.height / imageSize.width);
                        final containerSize = Size(width, height);

                        final fittedRect = fittedRectForContain(
                          containerSize: containerSize,
                          imageSize: imageSize,
                        );

                        return SizedBox(
                          width: width,
                          height: height,
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
                                final pos = pixelFromNormalized(
                                  fittedRect: fittedRect,
                                  x: p.x,
                                  y: p.y,
                                );

                                final cs = theme.colorScheme;

                                return Positioned(
                                  left: pos.dx - markerHaloRadius,
                                  top: pos.dy - markerHaloRadius,
                                  width: markerHaloRadius * 2,
                                  height: markerHaloRadius * 2,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _showMarkerSheet(
                                      entryId: entry.id,
                                      placement: p,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withAlpha(90),
                                          ),
                                          child: const SizedBox.expand(),
                                        ),
                                        SizedBox(
                                          width: markerRadius * 2,
                                          height: markerRadius * 2,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: cs.primary,
                                              border: Border.all(
                                                color: cs.surface,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
