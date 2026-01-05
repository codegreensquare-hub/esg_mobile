import 'package:flutter/material.dart';
import 'package:esg_mobile/data/models/supabase/enums/product_material.dart';
import 'package:esg_mobile/data/models/supabase/enums/product_style.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop/curation_section.all.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop/curation_section.best.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop/curation_section.style.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop/curation_section.type.dart';

const List<String> _curationTabIds = ['all', 'best', 'style', 'type'];
const List<String> _curationTabLabels = ['All', 'Best', 'Style', 'Type'];

class CurationShopTabController extends ChangeNotifier {
  CurationShopTabController({int initialIndex = 0})
    : _currentIndex = initialIndex.clamp(0, _curationTabIds.length - 1).toInt();

  int _currentIndex;

  int get currentIndex => _currentIndex;

  void selectIndex(int index) {
    final clamped = index.clamp(0, _curationTabIds.length - 1).toInt();
    if (clamped == _currentIndex) return;
    _currentIndex = clamped;
    notifyListeners();
  }

  void selectById(String id) {
    final idx = _curationTabIds.indexOf(id.toLowerCase());
    if (idx >= 0) {
      selectIndex(idx);
    }
  }
}

class CurationShopTab extends StatefulWidget {
  static const tab = 'curation_shop';
  const CurationShopTab({
    super.key,
    this.controller,
    this.onTapProduct,
  });

  final CurationShopTabController? controller;
  final ValueChanged<ProductWithOtherDetails>? onTapProduct;

  @override
  State<CurationShopTab> createState() => _CurationShopTabState();
}

class _CurationShopTabState extends State<CurationShopTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CurationShopTabController _controller;
  late final bool _ownsController;
  String _styleSubTab = ProductStyle.values.first.name;
  String _typeSubTab = ProductMaterial.values.first.name;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CurationShopTabController();
    _ownsController = widget.controller == null;
    _tabController = TabController(
      length: _curationTabIds.length,
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
              tabs: _curationTabLabels
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
        return CurationSectionAll(onTapProduct: widget.onTapProduct);
      case 1:
        return CurationSectionBest(onTapProduct: widget.onTapProduct);
      case 2:
        return CurationSectionStyle(
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
        return CurationSectionType(
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
