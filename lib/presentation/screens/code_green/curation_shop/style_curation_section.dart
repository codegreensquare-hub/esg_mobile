import 'package:flutter/material.dart';
import 'section_container.dart';

class StyleCurationSection extends StatelessWidget {
  const StyleCurationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionContainer(
      key: const ValueKey('curation-style'),
      title: 'Shop by Style',
      description: 'Find totes, cross bags, and more by vibe.',
      color: theme.colorScheme.secondaryContainer,
    );
  }
}