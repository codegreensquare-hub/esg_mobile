import 'package:flutter/material.dart';

/// Responsive floating navigation header.
///
/// Displays full tab buttons on wide layouts (>= [breakpointWidth]) and a menu
/// icon (hamburger) on narrow layouts. Safe-area top padding is externally
/// computed and passed via [topPad].
class CodeGreenNavHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ThemeData theme;
  final double toolbarHeight;
  final double topPad; // dynamic safe-top padding based on scroll
  final List<String> tabs;
  final int selectedIndex;
  final void Function(int index, String tab)? onTabSelected;
  final void Function()? onTapMenu;
  final double breakpointWidth;

  CodeGreenNavHeaderDelegate({
    required this.theme,
    required this.toolbarHeight,
    required this.topPad,
    required this.tabs,
    this.selectedIndex = 0,
    this.onTabSelected,
    this.onTapMenu,
    this.breakpointWidth = 600,
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
    final width = MediaQuery.of(context).size.width;
    final bool showAllTabs = width >= breakpointWidth && tabs.isNotEmpty;

    return Material(
      color: theme.colorScheme.surfaceContainer,

      elevation: overlapsContent ? 4 : 0,
      child: Padding(
        padding: EdgeInsets.only(top: topPad, left: 8, right: 8, bottom: 0),
        child: Container(
          height: toolbarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Branding / Title
              Text(
                'Code Green',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 24),
              // Expanded region for tabs or spacer.
              if (showAllTabs)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < tabs.length; i++)
                          _NavTabButton(
                            label: tabs[i],
                            selected: i == selectedIndex,
                            theme: theme,
                            onTap: () => onTabSelected?.call(i, tabs[i]),
                          ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),
              // Menu icon for narrow layouts.
              if (!showAllTabs)
                IconButton(
                  tooltip: 'Menu',
                  icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
                  onPressed: onTapMenu,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant CodeGreenNavHeaderDelegate oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.toolbarHeight != toolbarHeight ||
        oldDelegate.topPad != topPad ||
        oldDelegate.tabs != tabs ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.breakpointWidth != breakpointWidth;
  }
}

class _NavTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final ThemeData theme;
  final VoidCallback? onTap;

  const _NavTabButton({
    required this.label,
    required this.selected,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = theme.colorScheme;
    final baseStyle = theme.textTheme.labelLarge;
    final style = baseStyle?.copyWith(
      color: selected ? cs.primary : cs.onSurfaceVariant,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? cs.primaryContainer : cs.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: style),
        ),
      ),
    );
  }
}
