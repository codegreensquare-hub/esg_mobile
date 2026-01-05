import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({
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
            '리뷰',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('아직 리뷰가 없습니다.'),
          ),
        ],
      ),
    );
  }
}
