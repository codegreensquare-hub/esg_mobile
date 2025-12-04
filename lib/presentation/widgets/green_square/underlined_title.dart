import 'package:flutter/material.dart';

class UnderlinedTitle extends StatelessWidget {
  const UnderlinedTitle(
    this.title, {
    super.key,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 8,
              color: const Color(0xFFC0D5CC),
            ),
          ),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
