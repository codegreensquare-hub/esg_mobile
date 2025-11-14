import 'package:flutter/material.dart';

/// A compact navigation header button that shows an icon with a small label
/// underneath, and exposes a tooltip. Intended for use in app bars/headers.
class NavHeaderButton extends StatelessWidget {
  const NavHeaderButton({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconSize = 22,
    this.spacing = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  });

  /// The icon to display.
  final IconData icon;

  /// The label shown under the icon and used for the tooltip.
  final String title;

  /// Tap callback. When null, the button is disabled.
  final VoidCallback? onTap;

  /// Icon size.
  final double iconSize;

  /// Vertical spacing between icon and label.
  final double spacing;

  /// Outer padding for hit area and layout.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool enabled = onTap != null;
    final Color baseColor = enabled
        ? cs.onSurface
        : cs.onSurfaceVariant.withValues(alpha: 0.6);
    final TextStyle? labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: baseColor,
    );

    // Ensure there's a Material ancestor for proper ink reactions.
    return Tooltip(
      message: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: baseColor),
              SizedBox(height: spacing),
              Text(title, style: labelStyle, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
