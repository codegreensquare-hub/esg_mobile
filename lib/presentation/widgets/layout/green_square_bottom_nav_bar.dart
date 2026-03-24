import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GreenSquareBottomNavBar extends StatefulWidget {
  const GreenSquareBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onGreenButtonPressed,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onGreenButtonPressed;

  @override
  State<GreenSquareBottomNavBar> createState() =>
      _GreenSquareBottomNavBarState();
}

class _GreenSquareBottomNavBarState extends State<GreenSquareBottomNavBar> {
  bool _isGreenHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Container(
      color: cs.surface,
      child: SafeArea(
        bottom: true,
        left: false,
        right: false,
        child: Container(
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          index: 0,
                          offIconAssetPath: 'assets/images/nav_bar/off_stories.svg',
                          onIconAssetPath: 'assets/images/nav_bar/on_stories.svg',
                          label: '스토리',
                          selected: widget.selectedIndex == 0,
                          onTap: () => widget.onItemSelected(0),
                        ),
                        _NavItem(
                          index: 1,
                          offIconAssetPath: 'assets/images/nav_bar/off_shop.svg',
                          onIconAssetPath: 'assets/images/nav_bar/on_shop.svg',
                          label: '쇼핑몰',
                          selected: widget.selectedIndex == 1,
                          onTap: () => widget.onItemSelected(1),
                        ),
                        // add empty space for the center button
                        const SizedBox(width: 36),
                        _NavItem(
                          index: 2,
                          offIconAssetPath: 'assets/images/nav_bar/off_missions.svg',
                          onIconAssetPath: 'assets/images/nav_bar/on_missions.svg',
                          label: '미션 참여',
                          selected: widget.selectedIndex == 2,
                          onTap: () => widget.onItemSelected(2),
                        ),
                        _NavItem(
                          index: 3,
                          offIconAssetPath: 'assets/images/nav_bar/off_profile.svg',
                          onIconAssetPath: 'assets/images/nav_bar/on_profile.svg',
                          label: '나의 콕',
                          selected: widget.selectedIndex == 3,
                          onTap: () => widget.onItemSelected(3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: size.width / 2 - 28,
                child: Transform.translate(
                  offset: const Offset(0, -48),
                  child: Tooltip(
                    message: 'See Missions',
                    preferBelow: false,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _isGreenHovered = true),
                      onExit: (_) => setState(() => _isGreenHovered = false),
                      child: GestureDetector(
                        onTap: widget.onGreenButtonPressed,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: cs.shadow.withValues(
                                  alpha: _isGreenHovered ? 0.5 : 0.3,
                                ),
                                blurRadius: _isGreenHovered ? 12 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "콕!",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.index,
    required this.offIconAssetPath,
    required this.onIconAssetPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final String offIconAssetPath;
  final String onIconAssetPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;
  static const Color _activeLabelColor = Color(0xFF355148);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final Color color = widget.selected
        ? _activeLabelColor
        : (_isHovered
              ? cs.primary.withValues(alpha: 0.7)
              : cs.onSurfaceVariant);
    final iconAssetPath = widget.selected
        ? widget.onIconAssetPath
        : widget.offIconAssetPath;
    final TextStyle textStyle = widget.selected
        ? theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ) ??
              const TextStyle()
        : theme.textTheme.labelSmall?.copyWith(color: color) ??
              const TextStyle();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: SizedBox(
                  key: ValueKey(iconAssetPath),
                  width: 24,
                  height: 24,
                  child: _buildNavIcon(iconAssetPath),
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: textStyle,
                child: Text(
                  widget.label,
                  key: ValueKey('${widget.label}_${widget.selected}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(String assetPath) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
      );
    }
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
    );
  }
}

class FloatingActionButtonWithBadge extends StatelessWidget {
  const FloatingActionButtonWithBadge({
    required this.icon,
    required this.badgeCount,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final int badgeCount;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('Tapped floating button: $tooltip');
          onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor ?? cs.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: iconColor ?? cs.onSurface,
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Badge(
                      backgroundColor: Colors.black,
                      label: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KakaoTalkButton extends StatelessWidget {
  const KakaoTalkButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Tooltip(
      message: '카카오톡 문의',
      preferBelow: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('Tapped KakaoTalk button');
          onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE500), // KakaoTalk yellow
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/images/icons/kakao-icon.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScrollUpButton extends StatelessWidget {
  const ScrollUpButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Tooltip(
      message: '맨 위로',
      preferBelow: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('Tapped scroll up button');
          onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_arrow_up,
                  color: cs.onSurface,
                  size: 20,
                ),
                Text(
                  '올라가기',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
