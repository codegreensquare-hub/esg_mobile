import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/green_square/review_images_fullscreen.screen.dart';
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
  List<ProductReviewImageRow> allImages = [];
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

      final newImages = <ProductReviewImageRow>[];
      for (final review in newReviews) {
        final imagesData =
            review.data['product_review_image'] as List<dynamic>? ?? [];
        newImages.addAll(
          imagesData.map(
            (img) =>
                ProductReviewImageRow.fromJson(img as Map<String, dynamic>),
          ),
        );
      }

      setState(() {
        if (loadMore) {
          reviews.addAll(newReviews);
          allImages.addAll(newImages);
          currentOffset += newReviews.length;
          hasMore = newReviews.length == pageSize;
          isLoadingMore = false;
        } else {
          reviews = newReviews;
          allImages = newImages;
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                      children: List.generate(5, (index) {
                        final isFilled = index < review.stars.round();
                        return Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
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
                    const SizedBox(height: 2),
                    Text(
                      'by ${(review.data['user'] as Map<String, dynamic>?)?['username'] as String? ?? 'Anonymous'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
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
          if (allImages.isNotEmpty) ...[
            GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                allImages.length > 6 ? 6 : allImages.length,
                (index) {
                  if (index == 5 && allImages.length > 6) {
                    // See more
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReviewImagesFullscreen(
                              images: allImages,
                              initialIndex: 0,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '+${allImages.length - 5}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    final image = allImages[index];
                    final url = getImageLink(
                      image.bucket ?? '',
                      image.fileName ?? '',
                      folderPath: image.folderPath,
                    );
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReviewImagesFullscreen(
                              images: allImages,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'review-image-${image.id}',
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
