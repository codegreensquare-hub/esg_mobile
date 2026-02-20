import 'package:flutter/material.dart';

class FaqCard extends StatelessWidget {
  const FaqCard({
    super.key,
    required this.question,
    required this.answer,
    this.showDivider = true,
  });

  final String question;
  final String answer;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.help_outline,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Divider(height: 1, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
