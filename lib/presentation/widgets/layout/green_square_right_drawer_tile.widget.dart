import 'package:flutter/material.dart';

class GreenSquareRightDrawerTile extends StatelessWidget {
  const GreenSquareRightDrawerTile({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  static const _drawerTextColor = Color(0xFF3B3733);
  static const _horizontalPadding = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      minVerticalPadding: 4,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: _drawerTextColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
