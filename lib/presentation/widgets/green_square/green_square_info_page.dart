import 'package:flutter/material.dart';

class GreenSquareInfoPage extends StatelessWidget {
  const GreenSquareInfoPage({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = children
        .map(
          (child) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: child,
          ),
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content.isEmpty
              ? [
                  Text(
                    '콘텐츠를 준비 중입니다.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ]
              : content,
        ),
      ),
    );
  }
}
