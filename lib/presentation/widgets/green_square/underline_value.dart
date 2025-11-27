import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UnderlineValue extends StatelessWidget {
  const UnderlineValue({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedValue = NumberFormat('#,###').format(value);
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: 150,
                  height: 12,
                  color: const Color(0xFF256a54), // Green color
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '   '),
                    TextSpan(
                      text: formattedValue,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: ' 회',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: '  '),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
