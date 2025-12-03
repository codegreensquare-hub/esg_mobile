import 'package:flutter/material.dart';

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
  const CurationShopTab({super.key, this.controller});

  final CurationShopTabController? controller;

  @override
  State<CurationShopTab> createState() => _CurationShopTabState();
}

class _CurationShopTabState extends State<CurationShopTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CurationShopTabController _controller;
  late final bool _ownsController;

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
    _controller.selectIndex(_tabController.index);
    setState(() {});
  }

  void _handleControllerChange() {
    if (_controller.currentIndex == _tabController.index) return;
    _tabController.animateTo(_controller.currentIndex);
    setState(() {});
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
            child: _buildSection(currentIndex, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(int index, ThemeData theme) {
    switch (index) {
      case 0:
        return _SectionContainer(
          key: const ValueKey('curation-all'),
          title: 'All Collections',
          description: 'Browse every curated drop from CodeGreen designers.',
          color: theme.colorScheme.surfaceContainerHighest,
        );
      case 1:
        return _SectionContainer(
          key: const ValueKey('curation-best'),
          title: 'Best Sellers',
          description: 'Community favorites refreshed weekly.',
          color: theme.colorScheme.primaryContainer,
        );
      case 2:
        return _SectionContainer(
          key: const ValueKey('curation-style'),
          title: 'Shop by Style',
          description: 'Find totes, cross bags, and more by vibe.',
          color: theme.colorScheme.secondaryContainer,
        );
      case 3:
      default:
        return _SectionContainer(
          key: const ValueKey('curation-type'),
          title: 'Shop by Type',
          description: 'Filter by material sources and sustainability type.',
          color: theme.colorScheme.tertiaryContainer,
        );
    }
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    super.key,
    required this.title,
    required this.description,
    required this.color,
  });

  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () {},
            child: const Text('Explore'),
          ),
        ],
      ),
    );
  }
}
