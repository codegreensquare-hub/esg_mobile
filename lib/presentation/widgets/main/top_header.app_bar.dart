import 'package:flutter/material.dart';

/// A reusable top-level AppBar for primary screens.
///
/// Provides optional [title], [actions], and [leading] customizations while
/// keeping a consistent height and style across the app.
class TopHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool centerTitle;

  const TopHeaderAppBar({
    super.key,
    this.title = 'Code Green Home',
    this.actions,
    this.leading,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
