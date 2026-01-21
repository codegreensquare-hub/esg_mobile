import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDescriptionTab extends StatefulWidget {
  const ProductDescriptionTab({
    super.key,
    required this.product,
  });

  final ProductRow product;

  @override
  State<ProductDescriptionTab> createState() => _ProductDescriptionTabState();
}

class _ProductDescriptionTabState extends State<ProductDescriptionTab> {
  Future<List<String>>? _imageUrlsFuture;
  Future<List<String>>? _productImagesFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlsFuture = _fetchDescriptionImageUrls();
    _productImagesFuture = _fetchProductImages();
  }

  @override
  void didUpdateWidget(covariant ProductDescriptionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      _imageUrlsFuture = _fetchDescriptionImageUrls();
      _productImagesFuture = _fetchProductImages();
    }
  }

  Future<List<String>> _fetchDescriptionImageUrls() async {
    final productId = widget.product.id.trim();
    if (productId.isEmpty) return const [];

    final client = Supabase.instance.client;

    final descriptionRows = await client
        .from(ProductImageDescriptionTable().tableName)
        .select()
        .eq(ProductImageDescriptionRow.productField, productId)
        .order(ProductImageDescriptionRow.createdAtField, ascending: true);

    final legacyRows = await client
        .from(ProductImageTable().tableName)
        .select()
        .eq(ProductImageRow.productField, productId)
        .eq(ProductImageRow.folderPathField, 'description')
        .order(ProductImageRow.createdAtField, ascending: true);

    final newUrls = (descriptionRows as List)
        .whereType<Map<String, dynamic>>()
        .map(ProductImageDescriptionRow.fromJson)
        .where(
          (row) =>
              (row.bucket ?? '').trim().isNotEmpty &&
              (row.fileName ?? '').trim().isNotEmpty,
        )
        .map(
          (row) => getImageLink(
            row.bucket!.trim(),
            row.fileName!.trim(),
            folderPath: (row.folderPath ?? '').trim().isEmpty
                ? null
                : row.folderPath!.trim(),
          ),
        );

    final legacyUrls = (legacyRows as List)
        .whereType<Map<String, dynamic>>()
        .map(ProductImageRow.fromJson)
        .where(
          (row) =>
              (row.bucket ?? '').trim().isNotEmpty &&
              (row.fileName ?? '').trim().isNotEmpty,
        )
        .map(
          (row) => getImageLink(
            row.bucket!.trim(),
            row.fileName!.trim(),
            folderPath: (row.folderPath ?? '').trim().isEmpty
                ? null
                : row.folderPath!.trim(),
          ),
        );

    final allUrls = [
      ...newUrls,
      ...legacyUrls,
    ].map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);

    return allUrls.fold<List<String>>(
      <String>[],
      (acc, url) => acc.contains(url) ? acc : [...acc, url],
    );
  }

  Future<List<String>> _fetchProductImages() async {
    final productId = widget.product.id.trim();
    if (productId.isEmpty) return const [];

    final client = Supabase.instance.client;

    // Fetch thumbnail
    final thumbnailUrl =
        widget.product.mainImageBucket != null &&
            widget.product.mainImageFileName != null
        ? getImageLink(
            widget.product.mainImageBucket!.trim(),
            widget.product.mainImageFileName!.trim(),
            folderPath: widget.product.mainImageFolderPath?.trim(),
          )
        : null;

    // Fetch all product images
    final imageRows = await client
        .from(ProductImageTable().tableName)
        .select()
        .eq(ProductImageRow.productField, productId)
        .order(ProductImageRow.createdAtField, ascending: true);

    final imageUrls = (imageRows as List)
        .whereType<Map<String, dynamic>>()
        .map(ProductImageRow.fromJson)
        .where(
          (row) =>
              (row.bucket ?? '').trim().isNotEmpty &&
              (row.fileName ?? '').trim().isNotEmpty,
        )
        .map(
          (row) => getImageLink(
            row.bucket!.trim(),
            row.fileName!.trim(),
            folderPath: (row.folderPath ?? '').trim().isEmpty
                ? null
                : row.folderPath!.trim(),
          ),
        )
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Combine thumbnail and images, removing duplicates
    final allImages =
        [
          if (thumbnailUrl != null) thumbnailUrl,
          ...imageUrls,
        ].fold<List<String>>(
          <String>[],
          (acc, url) => acc.contains(url) ? acc : [...acc, url],
        );

    return allImages;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<String>>(
          future: _imageUrlsFuture,
          builder: (context, snapshot) {
            final urls = snapshot.data ?? const <String>[];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  height: 400,
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                '상세 이미지를 불러오지 못했습니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              );
            }

            if (urls.isEmpty) {
              return FutureBuilder<List<String>>(
                future: _productImagesFuture,
                builder: (context, imageSnapshot) {
                  final productImages = imageSnapshot.data ?? const <String>[];
                  final description = widget.product.description?.trim() ?? '';

                  return Container(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (description.isNotEmpty) ...[
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (productImages.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount: productImages.length,
                            itemBuilder: (context, index) {
                              final imageUrl = productImages[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: cs.surfaceContainerHighest,
                                      alignment: Alignment.center,
                                      child:
                                          const CircularProgressIndicator.adaptive(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: cs.surfaceContainerHighest,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...urls.map(
                  (url) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 240,
                            color: cs.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator.adaptive(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 240,
                          color: cs.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
