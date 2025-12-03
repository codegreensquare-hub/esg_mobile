import 'package:flutter/material.dart';
import 'curation_shop.product_fetch.dart';

class CurationSectionStyle extends StatelessWidget {
  const CurationSectionStyle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop by Style',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Find totes, cross bags, and more by vibe.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        const CurationShopProductFetch(tab: 'style'),
      ],
    );
  }
}
