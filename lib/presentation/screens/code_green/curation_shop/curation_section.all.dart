import 'package:flutter/material.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'curation_shop.product_fetch.dart';

class CurationSectionAll extends StatelessWidget {
  const CurationSectionAll({super.key, this.onTapProduct});

  final ValueChanged<ProductWithOtherDetails>? onTapProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'All Collections',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Browse every curated drop from CodeGreen designers.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        CurationShopProductFetch(
          tab: 'all',
          onTapProduct: onTapProduct,
          isCuration: true,
        ),
      ],
    );
  }
}
