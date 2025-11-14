import 'package:flutter/material.dart';

class CodeGreenLogo extends StatelessWidget {
  const CodeGreenLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Temporarily text
    // TODO change to image asset
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        'Code Green',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
