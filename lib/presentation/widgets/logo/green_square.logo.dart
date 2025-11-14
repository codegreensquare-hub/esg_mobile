import 'package:flutter/material.dart';

class GreenSquareLogo extends StatelessWidget {
  const GreenSquareLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Temporarily text
    // TODO change to image asset
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        'Green Square',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
