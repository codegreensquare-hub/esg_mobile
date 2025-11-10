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

    final codeGreenTabs = [
      HomeTab.tab,
      OriginalShopTab.tab,
      CurationShopTab.tab,
      AboutTab.tab,
      LookBookTab.tab,
      EventTab.tab,
    ];

    final tabNames = {
      HomeTab.tab: 'Home',
      OriginalShopTab.tab: 'Original Shop',
      CurationShopTab.tab: 'Curation Shop',
      AboutTab.tab: 'About',
      LookBookTab.tab: 'Look Book',
      EventTab.tab: 'Event',
    };

    String currentTab = HomeTab.tab;

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
              tabs: codeGreenTabs,
              theme: theme,
              toolbarHeight: _toolbarHeight,
              topPad: topPad,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              constraints: BoxConstraints(minHeight: 600),
              color: theme.colorScheme.surface,
              child: Center(
                child: Text(
                  'Main Content Area',
                  style: theme.textTheme.headlineMedium,
                ),
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
}
