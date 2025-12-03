import 'package:flutter/material.dart';

class TextChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  const TextChip({
    required this.label,
    this.selected = false,
    this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: () => onSelected?.call(!selected),
      splashColor: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? cs.onSurface : cs.outline,
          ),
        ),
      ),
    );
  }
}
