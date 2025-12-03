import 'package:flutter/material.dart';
import 'section_container.dart';

class TypeCurationSection extends StatelessWidget {
  const TypeCurationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionContainer(
      key: const ValueKey('curation-type'),
      title: 'Shop by Type',
      description: 'Filter by material sources and sustainability type.',
      color: theme.colorScheme.tertiaryContainer,
    );
  }
}