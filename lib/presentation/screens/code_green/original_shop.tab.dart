import 'package:flutter/material.dart';
import 'package:esg_mobile/data/models/supabase/enums/product_material.dart';
import 'package:esg_mobile/data/models/supabase/enums/product_style.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop/curation_shop.product_fetch.dart';

const List<String> _originalTabIds = ['all', 'best', 'style', 'type'];
const List<String> _originalTabLabels = ['All', 'Best', 'Style', 'Type'];

class OriginalShopTabController extends ChangeNotifier {
  OriginalShopTabController({int initialIndex = 0})
    : _currentIndex = initialIndex.clamp(0, _originalTabIds.length - 1).toInt();

  int _currentIndex;

  int get currentIndex => _currentIndex;

  void selectIndex(int index) {
    final clamped = index.clamp(0, _originalTabIds.length - 1).toInt();
    if (clamped == _currentIndex) return;
    _currentIndex = clamped;
    notifyListeners();
  }

  void selectById(String id) {
    final idx = _originalTabIds.indexOf(id.toLowerCase());
    if (idx >= 0) {
      selectIndex(idx);
    }
  }
}

class OriginalShopTab extends StatefulWidget {
  static const tab = 'original_shop';
  const OriginalShopTab({
    super.key,
    this.controller,
    this.onTapProduct,
  });

  final OriginalShopTabController? controller;
  final ValueChanged<ProductWithOtherDetails>? onTapProduct;

  @override
  State<OriginalShopTab> createState() => _OriginalShopTabState();
}

class _OriginalShopTabState extends State<OriginalShopTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final OriginalShopTabController _controller;
  late final bool _ownsController;
  String _styleSubTab = ProductStyle.values.first.name;
  String _typeSubTab = ProductMaterial.values.first.name;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? OriginalShopTabController();
    _ownsController = widget.controller == null;
    _tabController = TabController(
      length: _originalTabIds.length,
      vsync: this,
      initialIndex: _controller.currentIndex,
    );
    _tabController.addListener(_handleTabChange);
    _controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _controller.removeListener(_handleControllerChange);
    _tabController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    _ensureDefaultForIndex(_tabController.index);
    _controller.selectIndex(_tabController.index);
    setState(() {});
  }

  void _handleControllerChange() {
    if (_controller.currentIndex == _tabController.index) return;
    _ensureDefaultForIndex(_controller.currentIndex);
    _tabController.animateTo(_controller.currentIndex);
    setState(() {});
  }

  void _ensureDefaultForIndex(int index) {
    if (index == 2 && !_isValidStyle(_styleSubTab)) {
      _styleSubTab = ProductStyle.values.first.name;
    } else if (index == 3 && !_isValidMaterial(_typeSubTab)) {
      _typeSubTab = ProductMaterial.values.first.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _controller.currentIndex;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              tabAlignment: TabAlignment.center,
              indicatorColor: theme.colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: _originalTabLabels
                  .map((label) => Tab(text: label))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: _buildSection(currentIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(int index) {
    switch (index) {
      case 0:
        return _OriginalSectionAll(onTapProduct: widget.onTapProduct);
      case 1:
        return _OriginalSectionBest(onTapProduct: widget.onTapProduct);
      case 2:
        return _OriginalSectionStyle(
          selectedSlug: _styleSubTab,
          onSubTabChanged: (value) {
            if (_isValidStyle(value)) {
              setState(() {
                _styleSubTab = value;
              });
            }
          },
          onTapProduct: widget.onTapProduct,
        );
      case 3:
      default:
        return _OriginalSectionType(
          selectedSlug: _typeSubTab,
          onSubTabChanged: (value) {
            if (_isValidMaterial(value)) {
              setState(() {
                _typeSubTab = value;
              });
            }
          },
          onTapProduct: widget.onTapProduct,
        );
    }
  }

  bool _isValidStyle(String? slug) {
    if (slug == null) return false;
    return ProductStyle.values.any((style) => style.name == slug);
  }

  bool _isValidMaterial(String? slug) {
    if (slug == null) return false;
    return ProductMaterial.values.any((material) => material.name == slug);
  }
}

// Original Shop Sections - similar to Curation sections but with isCuration: false

class _OriginalSectionAll extends StatelessWidget {
  const _OriginalSectionAll({this.onTapProduct});

  final ValueChanged<ProductWithOtherDetails>? onTapProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'All Products',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Browse every product from CodeGreen designers.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        CurationShopProductFetch(
          tab: 'all',
          onTapProduct: onTapProduct,
          isCuration: false,
        ),
      ],
    );
  }
}

class _OriginalSectionBest extends StatelessWidget {
  const _OriginalSectionBest({this.onTapProduct});

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
        CurationShopProductFetch(
          tab: 'best',
          onTapProduct: onTapProduct,
          isCuration: false,
        ),
      ],
    );
  }
}

class _OriginalSectionStyle extends StatelessWidget {
  const _OriginalSectionStyle({
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
    final initialIndex = _indexForStyleSlug(selectedSlug);
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
            isCuration: false,
          ),
        ],
      ),
    );
  }
}

int _indexForStyleSlug(String slug) {
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

class _OriginalSectionType extends StatelessWidget {
  const _OriginalSectionType({
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
    final initialIndex = _indexForMaterialSlug(selectedSlug);
    return DefaultTabController(
      length: ProductMaterial.values.length,
      initialIndex: initialIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            onTapProduct: onTapProduct,
            isCuration: false,
          ),
        ],
      ),
    );
  }
}

int _indexForMaterialSlug(String slug) {
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
