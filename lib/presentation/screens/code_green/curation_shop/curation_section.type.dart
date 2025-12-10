import 'package:flutter/material.dart';
import 'package:esg_mobile/data/models/supabase/enums/product_material.dart';
import 'curation_shop.product_fetch.dart';

class CurationSectionType extends StatelessWidget {
  const CurationSectionType({
    super.key,
    required this.selectedSlug,
    required this.onSubTabChanged,
  });

  final String selectedSlug;
  final ValueChanged<String> onSubTabChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initialIndex = _indexForSlug(selectedSlug);
    return DefaultTabController(
      length: ProductMaterial.values.length,
      initialIndex: initialIndex,
      child: Column(
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
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: ProductMaterial.values
                      .map((material) => Tab(text: _materialLabel(material)))
                      .toList(),
                  onTap: (index) =>
                      onSubTabChanged(ProductMaterial.values[index].name),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CurationShopProductFetch(
            tab: 'type',
            subTab: selectedSlug,
          ),
        ],
      ),
    );
  }
}

int _indexForSlug(String slug) {
  final matchIndex = ProductMaterial.values.indexWhere((m) => m.name == slug);
  return matchIndex >= 0 ? matchIndex : 0;
}

String _materialLabel(ProductMaterial material) {
  switch (material) {
    case ProductMaterial.nature_oriented:
      return 'Natural';
    case ProductMaterial.vegan:
      return 'Vegan';
    case ProductMaterial.biodegradable:
      return 'Biodegradable';
  }
}
