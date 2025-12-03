import 'package:flutter/material.dart';
import 'curation_shop.product_fetch.dart';

class CurationSectionBest extends StatelessWidget {
  const CurationSectionBest({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const CurationShopProductFetch(tab: 'best'),
      ],
    );
  }
}
