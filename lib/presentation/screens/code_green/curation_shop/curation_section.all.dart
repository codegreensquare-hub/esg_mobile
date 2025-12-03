import 'package:flutter/material.dart';
import 'curation_shop.product_fetch.dart';

class CurationSectionAll extends StatelessWidget {
  const CurationSectionAll({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Collections',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Browse every curated drop from CodeGreen designers.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        const CurationShopProductFetch(tab: 'all'),
      ],
    );
  }
}
