import 'package:flutter/material.dart';

class CodeGreenNavHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ThemeData theme;
  final double toolbarHeight;
  final double topPad; // dynamic safe-top padding based on scroll
  final List<String> tabs;
  final void Function(int index, String tab)? onTabSelected;

  CodeGreenNavHeaderDelegate({
    required this.theme,
    required this.toolbarHeight,
    required this.topPad,
    required this.tabs,
    this.onTabSelected,
  });

  @override
  double get minExtent => toolbarHeight + topPad;

  @override
  double get maxExtent => toolbarHeight + topPad;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: theme.colorScheme.surfaceContainer,
      elevation: overlapsContent ? 4 : 0,
      child: Padding(
        padding: EdgeInsets.only(top: topPad, left: 0, right: 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Code Green",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant CodeGreenNavHeaderDelegate oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.toolbarHeight != toolbarHeight ||
        oldDelegate.topPad != topPad;
  }
}
