import 'package:esg_mobile/presentation/screens/code_green/about.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/event.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/home.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/look_book.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/original_shop.tab.dart';
import 'package:esg_mobile/presentation/widgets/layout/footer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/nav_header.delegate.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  static const String route = '/';
  final ScrollController? controller;

  const MainScreen({super.key, this.controller});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;
  int _selectedIndex = 0; // active tab index

  static const double _topHeaderHeight =
      72; // header height excluding status bar
  static const double _toolbarHeight = 64; // floating bar height

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(() {
      final offset = _scrollController.hasClients
          ? _scrollController.position.pixels
          : 0.0;
      if (offset != _scrollOffset) {
        setState(() => _scrollOffset = offset);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeTop = MediaQuery.of(context).padding.top;

    // Compute how much of the status bar padding the floating header should include.
    //  - At scrollOffset = 0 (not floating): topPad = 0.
    //  - After scrolling past the top header + safeTop (floating at top): topPad = safeTop.
    final double removalEnd = safeTop + _topHeaderHeight;
    final double t = removalEnd <= 0
        ? 1.0
        : (_scrollOffset / removalEnd).clamp(0.0, 1.0);
    final double topPad = safeTop * t;

    // Tab identifiers; used internally for content selection.
    final tabIds = <String>[
      HomeTab.tab,
      OriginalShopTab.tab,
      CurationShopTab.tab,
      AboutTab.tab,
      LookBookTab.tab,
      EventTab.tab,
    ];

    // Active tab id derived from selected index.
    final String activeTabId = tabIds[_selectedIndex];

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        // physics: ClampingScrollPhysics(),
        slivers: [
          CodeGreenTopHeader(),

          SliverPersistentHeader(
            floating: true,
            pinned: false,
            delegate: CodeGreenNavHeaderDelegate(
              tabs: tabIds,
              theme: theme,
              toolbarHeight: _toolbarHeight,
              topPad: topPad,
              selectedIndex: _selectedIndex,
              onTabSelected: (index, _) {
                if (index != _selectedIndex) {
                  setState(() => _selectedIndex = index);
                }
              },
              onTapMenu: () => _showTabMenu(tabIds),
            ),
          ),
          // Animated tab content area
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: Container(
                padding: EdgeInsets.zero,
                key: ValueKey(activeTabId),
                constraints: const BoxConstraints(minHeight: 600),
                color: theme.colorScheme.surface,
                width: double.infinity,
                child: _buildTabContent(activeTabId),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: const CodeGreenFooter(),
          ),
        ],
      ),
    );
  }

  /// Returns the widget for the given tab id. Uses keys to preserve state.
  Widget _buildTabContent(String tabId) {
    switch (tabId) {
      case HomeTab.tab:
        return const HomeTab(key: PageStorageKey(HomeTab.tab));
      case OriginalShopTab.tab:
        return const OriginalShopTab(key: PageStorageKey(OriginalShopTab.tab));
      case CurationShopTab.tab:
        return const CurationShopTab(key: PageStorageKey(CurationShopTab.tab));
      case AboutTab.tab:
        return const AboutTab(key: PageStorageKey(AboutTab.tab));
      case LookBookTab.tab:
        return const LookBookTab(key: PageStorageKey(LookBookTab.tab));
      case EventTab.tab:
        return const EventTab(key: PageStorageKey(EventTab.tab));
      default:
        return const SizedBox.shrink();
    }
  }

  void _showTabMenu(List<String> tabIds) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: ListView.builder(
            itemCount: tabIds.length,
            itemBuilder: (context, index) {
              final id = tabIds[index];
              final selected = index == _selectedIndex;
              return ListTile(
                title: Text(
                  id,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                trailing: selected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  if (index != _selectedIndex) {
                    setState(() => _selectedIndex = index);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
