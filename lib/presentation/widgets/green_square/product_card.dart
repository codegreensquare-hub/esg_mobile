import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.productWithDetails,
  });

  final ProductWithOtherDetails productWithDetails;

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

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.code,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
                  '${product.salesPrice ?? product.regularPrice ?? 0} P',
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
