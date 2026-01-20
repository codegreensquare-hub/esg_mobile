import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';

class ReviewsTab extends StatefulWidget {
  const ReviewsTab({
    super.key,
    required this.productId,
    required this.averageStars,
  });

  final String productId;
  final double averageStars;

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  List<ProductReviewRow> reviews = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentOffset = 0;
  static const int pageSize = 8;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews({bool loadMore = false}) async {
    if (loadMore && !hasMore) return;

    setState(() {
      if (loadMore) {
        isLoadingMore = true;
      } else {
        isLoading = true;
      }
    });

    try {
      final newReviews = await ProductService.instance.fetchProductReviews(
        widget.productId,
        limit: pageSize,
        offset: loadMore ? currentOffset : 0,
      );

      setState(() {
        if (loadMore) {
          reviews.addAll(newReviews);
          currentOffset += newReviews.length;
          hasMore = newReviews.length == pageSize;
          isLoadingMore = false;
        } else {
          reviews = newReviews;
          currentOffset = newReviews.length;
          hasMore = newReviews.length == pageSize;
          isLoading = false;
        }
      });
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

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
          const SizedBox(height: 8),
          if (widget.averageStars > 0)
            Text(
              '${widget.averageStars.toStringAsFixed(1)} / 5',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (reviews.isEmpty)
            const Center(
              child: Text('아직 리뷰가 없습니다.'),
            )
          else
            ...reviews.map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${review.stars}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (review.review != null && review.review!.isNotEmpty)
                      Text(
                        review.review!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      review.createdAt.toString().split(' ')[0], // Date only
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (hasMore && !isLoading && !isLoadingMore)
            Center(
              child: TextButton(
                onPressed: () => _loadReviews(loadMore: true),
                child: const Text('더 보기'),
              ),
            ),
          if (isLoadingMore) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
