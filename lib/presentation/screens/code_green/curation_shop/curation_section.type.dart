import 'package:flutter/material.dart';
import 'curation_shop.product_fetch.dart';

class CurationSectionType extends StatelessWidget {
  const CurationSectionType({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop by Type',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Filter by material sources and sustainability type.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        const CurationShopProductFetch(tab: 'type'),
      ],
    );
  }
}
