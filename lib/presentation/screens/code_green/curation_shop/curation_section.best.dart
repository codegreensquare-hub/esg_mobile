import 'package:flutter/material.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'curation_shop.product_fetch.dart';

class CurationSectionBest extends StatelessWidget {
  const CurationSectionBest({super.key, this.onTapProduct});

  final ValueChanged<ProductWithOtherDetails>? onTapProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Best Sellers',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Community favorites refreshed weekly.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        CurationShopProductFetch(tab: 'best', onTapProduct: onTapProduct),
      ],
    );
  }
}
