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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '소싱이나 협업으로 만든 가방에 \ncode green 의 가치와 솔루션을 추가한 라인입니다.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: const Color(0xFF979797),
              ),
              textAlign: TextAlign.center,
            ),
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
