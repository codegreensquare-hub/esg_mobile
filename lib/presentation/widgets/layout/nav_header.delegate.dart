import 'package:esg_mobile/core/constants/frame_width.dart';
import 'dart:async';
import 'package:esg_mobile/core/enums/device.dart';
import 'package:esg_mobile/presentation/widgets/layout/nav_header.button.dart';
import 'package:esg_mobile/presentation/widgets/logo/code_green.logo.dart';
import 'package:esg_mobile/presentation/widgets/logo/green_square.logo.dart';
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
    required this.currentWidth,
    this.labels = const {},
    this.selectedIndex = 0,
    this.onTabSelected,
    this.onTapMenu,
    this.onTapLogin,
    this.onTapCart,
    this.homeTab,
    this.onSelectSubTab,
  });

  final ThemeData theme;
  final double toolbarHeight;
  final double topPad; // dynamic safe-top padding based on scroll
  final List<String> tabs;
  final Map<String, String> labels;
  final int selectedIndex;
  final void Function(int index, String tab)? onTabSelected;
  final void Function(String parentTab, String subTab)? onSelectSubTab;
  final void Function()? onTapMenu;
  final VoidCallback? onTapLogin;
  final VoidCallback? onTapCart;
  final String? homeTab;
  // Current layout width supplied by parent (e.g. LayoutBuilder). We only
  // rebuild when this crosses a breakpoint (narrow <-> wide) or other props change.
  final double currentWidth;

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
    final wideMode = _isWide(currentWidth);

    return Material(
      color: theme.colorScheme.surface,
      elevation: overlapsContent ? 4 : 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.only(
            top: topPad,
            left: wideMode ? defaultPadding : 5,
            right: wideMode ? defaultPadding : 5,
            bottom: 0,
          ),
          constraints: BoxConstraints(
            maxWidth: frameWidth + defaultPadding * 2,
          ),
          child: Row(
            children: [
              if (!wideMode) ...[
                IconButton(
                  tooltip: 'Menu',
                  icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
                  onPressed: onTapMenu,
                ),
                Spacer(),
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
                  child: CodeGreenLogo(),
                ),
                Spacer(),
                IconButton(
                  tooltip: 'User',
                  icon: Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: onTapLogin,
                ),
                IconButton(
                  tooltip: 'Shopping',
                  icon: Icon(
                    Icons.shopping_bag_outlined,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: onTapCart ?? onTapMenu,
                ),
              ],
              // Expanded region for tabs or spacer.
              if (wideMode) ...[
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
                  child: CodeGreenLogo(),
                ),
                Spacer(),
                ...tabs
                    .asMap()
                    .entries
                    .where(
                      (e) =>
                          !(homeTab != null && e.value == homeTab) &&
                          e.value != codeGreenProductTabId &&
                          e.value != codeGreenLoginTabId,
                    )
                    .map(
                      (e) => _NavTabButton(
                        id: e.value,
                        label: _labelFor(e.value) ?? e.value,
                        selected: e.key == selectedIndex,
                        theme: theme,
                        onTap: () => onTabSelected?.call(e.key, e.value),
                        subTabs:
                            (codeGreenSubTabs[e.value] as List?)
                                ?.cast<String>() ??
                            const <String>[],
                        onSelectSubTab: (subTab) =>
                            onSelectSubTab?.call(e.value, subTab),
                      ),
                    ),
                GreenSquareLogo(),
                Spacer(),
                // Logout
                NavHeaderButton(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    // TODO
                    throw UnimplementedError();
                  },
                ),
                // My
                NavHeaderButton(
                  icon: Icons.person_outline,
                  title: 'Login',
                  onTap: onTapLogin,
                ),
                // Cart
                NavHeaderButton(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Cart',
                  onTap: onTapCart,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant CodeGreenNavHeaderDelegate oldDelegate) {
    // Rebuild only when something meaningful changes: theme, sizing, tabs,
    // selection, labels, homeTab, or when width crosses breakpoint boundary.
    final prevWide = _isWide(oldDelegate.currentWidth);
    final nextWide = _isWide(currentWidth);
    return oldDelegate.theme != theme ||
        oldDelegate.toolbarHeight != toolbarHeight ||
        oldDelegate.topPad != topPad ||
        oldDelegate.tabs != tabs ||
        oldDelegate.labels != labels ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.homeTab != homeTab ||
        oldDelegate.onTapCart != onTapCart ||
        oldDelegate.onTapLogin != onTapLogin ||
        oldDelegate.onSelectSubTab != onSelectSubTab ||
        prevWide != nextWide;
  }

  bool _isWide(double width) => width >= Device.smallTablet.breakpoint;
}

class _NavTabButton extends StatefulWidget {
  final String id;
  final String label;
  final bool selected;
  final ThemeData theme;
  final VoidCallback? onTap;
  final List<String> subTabs;
  final void Function(String subTab)? onSelectSubTab;

  const _NavTabButton({
    required this.id,
    required this.label,
    required this.selected,
    required this.theme,
    this.onTap,
    this.subTabs = const <String>[],
    this.onSelectSubTab,
  });

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
            onSelect: widget.onSelectSubTab,
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
    return MouseRegion(
      onEnter: (event) {
        // Cancel any pending hide when moving between tabs to prevent blink.
        if (widget.subTabs.isEmpty) return _DropdownOverlay.hide();
        _DropdownOverlay.cancelHide();
        _showDropdown();
      },
      onExit: (event) {
        // If the pointer leaves the tab button and doesn't enter the menu,
        // close the dropdown shortly after.
        _DropdownOverlay.scheduleHide(const Duration(milliseconds: 120));
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
    );
  }
}

class _HoverMenu extends StatelessWidget {
  final List<String> items;
  final VoidCallback onDismiss;
  final void Function(String value)? onSelect;

  const _HoverMenu({
    required this.items,
    required this.onDismiss,
    this.onSelect,
  });

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
                  onTap: () {
                    onSelect?.call(e);
                    onDismiss();
                  },
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
  static Timer? _hideTimer;
  static void show(BuildContext context, OverlayEntry entry) {
    hide();
    Overlay.of(context).insert(entry);
    _entry = entry;
  }

  static void hide() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _entry?.remove();
    _entry = null;
  }

  static void setHovered(bool value) {
    _hovered = value;
  }

  // no getter needed; internal state checked within scheduleHide

  static void scheduleHide(Duration delay) {
    _hideTimer?.cancel();
    _hideTimer = Timer(delay, () {
      if (!_hovered) {
        hide();
      }
    });
  }

  static void cancelHide() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }
}

String _toTitleCase(String id) {
  if (id.isEmpty) return id;
  final parts = id.split('_').where((p) => p.isNotEmpty);
  return parts
      .map((p) => p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : ''))
      .join(' ');
}
