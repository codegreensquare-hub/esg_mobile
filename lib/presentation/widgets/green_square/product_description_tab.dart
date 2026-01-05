import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';

class ProductDescriptionTab extends StatelessWidget {
  const ProductDescriptionTab({
    super.key,
    required this.product,
  });

  final ProductRow product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '제품 상세 설명',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.description ?? '제품 설명이 없습니다.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
