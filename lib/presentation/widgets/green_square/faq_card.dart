import 'package:flutter/material.dart';

class FaqCard extends StatefulWidget {
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
  State<FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Q. ${widget.question}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Noto Sans KR',
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                fontFamily: 'Noto Sans KR',
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
        Divider(height: 1, color: theme.colorScheme.outline),
      ],
    );
  }
}
