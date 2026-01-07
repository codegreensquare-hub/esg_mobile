import 'package:flutter/material.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/enums/product_style.dart';
import 'curation_shop.product_fetch.dart';

class CurationSectionStyle extends StatelessWidget {
  const CurationSectionStyle({
    super.key,
    required this.selectedSlug,
    required this.onSubTabChanged,
    this.onTapProduct,
  });

  final String selectedSlug;
  final ValueChanged<String> onSubTabChanged;
  final ValueChanged<ProductWithOtherDetails>? onTapProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initialIndex = _indexForSlug(selectedSlug);
    return DefaultTabController(
      length: ProductStyle.values.length,
      initialIndex: initialIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: ProductStyle.values
                      .map((style) => Tab(text: _styleLabel(style)))
                      .toList(),
                  onTap: (index) =>
                      onSubTabChanged(ProductStyle.values[index].name),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CurationShopProductFetch(
            tab: 'style',
            subTab: selectedSlug,
            onTapProduct: onTapProduct,
            isCuration: true,
          ),
        ],
      ),
    );
  }
}

int _indexForSlug(String slug) {
  final matchIndex = ProductStyle.values.indexWhere((s) => s.name == slug);
  return matchIndex >= 0 ? matchIndex : 0;
}

String _styleLabel(ProductStyle style) {
  switch (style) {
    case ProductStyle.tote:
      return 'Tote';
    case ProductStyle.cross:
      return 'Cross';
    case ProductStyle.shoulder:
      return 'Shoulder';
    case ProductStyle.accessories:
      return 'Accessories';
  }
}
