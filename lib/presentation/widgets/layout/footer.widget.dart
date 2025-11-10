import 'package:flutter/material.dart';

class CodeGreenFooter extends StatelessWidget {
  const CodeGreenFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        '© 2024 Code Green. All rights reserved.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
