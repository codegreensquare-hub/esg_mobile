import 'package:flutter/material.dart';
import 'section_container.dart';

class AllCurationSection extends StatelessWidget {
  const AllCurationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionContainer(
      key: const ValueKey('curation-all'),
      title: 'All Collections',
      description: 'Browse every curated drop from CodeGreen designers.',
      color: theme.colorScheme.surfaceContainerHighest,
    );
  }
}