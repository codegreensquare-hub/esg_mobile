import 'package:flutter/material.dart';

class CodeGreenHomeScreen extends StatefulWidget {
  const CodeGreenHomeScreen({super.key});

  @override
  State<CodeGreenHomeScreen> createState() => _CodeGreenHomeScreenState();
}

class _CodeGreenHomeScreenState extends State<CodeGreenHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  static const double _topHeaderHeight =
      72; // header height excluding status bar
  static const double _toolbarHeight = 64; // floating bar height

  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Top widget separate from the floating app bar.
          SliverAppBar(
            backgroundColor: theme.colorScheme.primary,
            primary: true,

            title: Text(
              'Top Header',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          // Custom floating header with dynamic top padding based on scroll position.
          SliverPersistentHeader(
            floating: true,
            pinned: false,
            delegate: _FloatingHeaderDelegate(
              theme: theme,
              title: 'Code Green Home',
              toolbarHeight: _toolbarHeight,
              topPad: topPad,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 1600)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: const Center(
              child: Text('Welcome to the Code Green Home Screen!'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ThemeData theme;
  final String title;
  final double toolbarHeight;
  final double topPad; // dynamic safe-top padding based on scroll

  _FloatingHeaderDelegate({
    required this.theme,
    required this.title,
    required this.toolbarHeight,
    required this.topPad,
  });

  @override
  double get minExtent => toolbarHeight + topPad; // current total height

  @override
  double get maxExtent => toolbarHeight + topPad; // constant during this build

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: theme.colorScheme.secondary,
      elevation: overlapsContent ? 4 : 0,
      child: Padding(
        padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FloatingHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.theme != theme ||
        oldDelegate.toolbarHeight != toolbarHeight ||
        oldDelegate.topPad != topPad;
  }
}
