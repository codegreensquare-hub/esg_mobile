import 'package:flutter/material.dart';
import 'package:esg_mobile/core/constants/navigation.dart';

/// Responsive floating navigation header.
///
/// Displays full tab buttons on wide layouts (>= [breakpointWidth]) and a menu
/// icon (hamburger) on narrow layouts. Safe-area top padding is externally
/// computed and passed via [topPad].
class CodeGreenNavHeaderDelegate extends SliverPersistentHeaderDelegate {
  CodeGreenNavHeaderDelegate({
    required this.theme,
    required this.toolbarHeight,
    required this.topPad,
    required this.tabs,
    this.labels = const {},
    this.selectedIndex = 0,
    this.onTabSelected,
    this.onTapMenu,
    this.breakpointWidth = 600,
    this.homeTab,
  });

  final ThemeData theme;
  final double toolbarHeight;
  final double topPad; // dynamic safe-top padding based on scroll
  final List<String> tabs;
  final Map<String, String> labels;
  final int selectedIndex;
  final void Function(int index, String tab)? onTabSelected;
  final void Function()? onTapMenu;
  final double breakpointWidth;
  final String? homeTab;

  @override
  double get minExtent => toolbarHeight + topPad;

  @override
  double get maxExtent => toolbarHeight + topPad;

  String? _labelFor(String id) => labels[id];

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final width = MediaQuery.of(context).size.width;
    final bool showAllTabs = width >= breakpointWidth && tabs.isNotEmpty;

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: overlapsContent ? 4 : 0,
      child: Padding(
        padding: EdgeInsets.only(top: topPad, left: 8, right: 8, bottom: 0),
        child: SizedBox(
          height: toolbarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Branding / Title (clickable to go Home)
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: homeTab == null
                    ? null
                    : () {
                        final int idx = tabs.indexOf(homeTab!);
                        if (idx >= 0) {
                          onTabSelected?.call(idx, tabs[idx]);
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Text(
                    'Code Green',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
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
                          if (!(homeTab != null && tabs[i] == homeTab))
                            _NavTabButton(
                              id: tabs[i],
                              label: _labelFor(tabs[i]) ?? tabs[i],
                              selected: i == selectedIndex,
                              theme: theme,
                              onTap: () => onTabSelected?.call(i, tabs[i]),
                              subTabs:
                                  (codeGreenSubTabs[tabs[i]] as List?)
                                      ?.cast<String>() ??
                                  const <String>[],
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
        oldDelegate.labels != labels ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.breakpointWidth != breakpointWidth ||
        oldDelegate.homeTab != homeTab;
  }
}

class _NavTabButton extends StatefulWidget {
  final String id;
  final String label;
  final bool selected;
  final ThemeData theme;
  final VoidCallback? onTap;
  final List<String> subTabs;

  const _NavTabButton({
    required this.id,
    required this.label,
    required this.selected,
    required this.theme,
    this.onTap,
    this.subTabs = const <String>[],
    Key? key,
  }) : super(key: key);

  @override
  State<_NavTabButton> createState() => _NavTabButtonState();
}

class _NavTabButtonState extends State<_NavTabButton> {
  void _showDropdown() {
    if (widget.subTabs.isEmpty) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final box = context.findRenderObject() as RenderBox?;
    if (overlayBox == null || box == null) return;
    final offset = box.localToGlobal(Offset.zero, ancestor: overlayBox);

    final entry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + box.size.height,
          child: _HoverMenu(
            items: widget.subTabs,
            onDismiss: _DropdownOverlay.hide,
          ),
        );
      },
    );
    _DropdownOverlay.show(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.theme.colorScheme;
    final baseStyle = widget.theme.textTheme.labelLarge;
    final style = baseStyle?.copyWith(
      color: widget.selected ? cs.primary : cs.onSurfaceVariant,
      fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: MouseRegion(
        onEnter: (event) {
          _DropdownOverlay.hide();
          _showDropdown();
        },
        onExit: (event) {
          // If the pointer leaves the tab button and doesn't enter the menu,
          // close the dropdown shortly after.
          Future.delayed(const Duration(milliseconds: 120), () {
            if (!mounted) return;
            if (!_DropdownOverlay.isHovered) {
              _DropdownOverlay.hide();
            }
          });
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.selected ? cs.primaryContainer : cs.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(widget.label, style: style),
          ),
        ),
      ),
    );
  }
}

class _HoverMenu extends StatelessWidget {
  final List<String> items;
  final VoidCallback onDismiss;

  const _HoverMenu({required this.items, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _DropdownOverlay.setHovered(true),
      onExit: (_) {
        _DropdownOverlay.setHovered(false);
        onDismiss();
      },
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final e in items)
                InkWell(
                  onTap: onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(_toTitleCase(e)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownOverlay {
  static OverlayEntry? _entry;
  static bool _hovered = false;
  static void show(BuildContext context, OverlayEntry entry) {
    hide();
    Overlay.of(context).insert(entry);
    _entry = entry;
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  static void setHovered(bool value) {
    _hovered = value;
  }

  static bool get isHovered => _hovered;
}

String _toTitleCase(String id) {
  if (id.isEmpty) return id;
  final parts = id.split('_').where((p) => p.isNotEmpty);
  return parts
      .map((p) => p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : ''))
      .join(' ');
}
