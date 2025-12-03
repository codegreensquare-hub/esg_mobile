import 'package:flutter/material.dart';
import 'section_container.dart';

class BestCurationSection extends StatelessWidget {
  const BestCurationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionContainer(
      key: const ValueKey('curation-best'),
      title: 'Best Sellers',
      description: 'Community favorites refreshed weekly.',
      color: theme.colorScheme.primaryContainer,
    );
  }
}