import 'package:flutter/material.dart';

class GreenSquareBottomNavBar extends StatelessWidget {
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
                          icon: Icons.auto_stories_outlined,
                          label: '스토리',
                          selected: selectedIndex == 0,
                          onTap: () => onItemSelected(0),
                        ),
                        _NavItem(
                          index: 1,
                          icon: Icons.storefront_outlined,
                          label: '쇼핑몰',
                          selected: selectedIndex == 1,
                          onTap: () => onItemSelected(1),
                        ),
                        // add empty space for the center button
                        const SizedBox(width: 36),
                        _NavItem(
                          index: 2,
                          icon: Icons.group_outlined,
                          label: '미션 참여',
                          selected: selectedIndex == 2,
                          onTap: () => onItemSelected(2),
                        ),
                        _NavItem(
                          index: 3,
                          icon: Icons.person_outline,
                          label: '나의 콕',
                          selected: selectedIndex == 3,
                          onTap: () => onItemSelected(3),
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
                  child: GestureDetector(
                    onTap: onGreenButtonPressed,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: cs.shadow.withValues(alpha: 0.3),
                            blurRadius: 8,
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
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final Color color = widget.selected
        ? cs.primary
        : (_isHovered
              ? cs.primary.withValues(alpha: 0.7)
              : cs.onSurfaceVariant);
    final IconData iconData = widget.selected
        ? _getSolidIcon(widget.icon)
        : widget.icon;
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
                child: Icon(
                  iconData,
                  key: ValueKey(iconData),
                  color: color,
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

  IconData _getSolidIcon(IconData outlinedIcon) {
    if (outlinedIcon == Icons.auto_stories_outlined) {
      return Icons.auto_stories;
    } else if (outlinedIcon == Icons.storefront_outlined) {
      return Icons.storefront;
    } else if (outlinedIcon == Icons.group_outlined) {
      return Icons.group;
    } else if (outlinedIcon == Icons.person_outline) {
      return Icons.person;
    }
    return outlinedIcon; // fallback
  }
}
