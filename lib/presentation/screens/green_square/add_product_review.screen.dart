import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class AddProductReviewScreen extends StatefulWidget {
  const AddProductReviewScreen({
    super.key,
    required this.orderItem,
    required this.product,
  });

  final OrderItemRow orderItem;
  final ProductRow? product;

  @override
  State<AddProductReviewScreen> createState() => _AddProductReviewScreenState();
}

class _AddProductReviewScreenState extends State<AddProductReviewScreen> {
  final _reviewController = TextEditingController();
  int _rating = 0;
  final List<XFile> _selectedImages = [];

  final _imagePicker = ImagePicker();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('별점을 선택해주세요.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final client = Supabase.instance.client;

      // Insert review
      final reviewResponse = await client
          .from(ProductReviewTable().tableName)
          .insert({
            ProductReviewRow.createdByField: userId,
            ProductReviewRow.starsField: _rating,
            ProductReviewRow.reviewField: _reviewController.text.trim(),
            ProductReviewRow.productField: widget.product?.id,
            ProductReviewRow.orderField: widget.orderItem.order,
          })
          .select()
          .single();

      final reviewId = reviewResponse['id'] as String;

      // Upload images
      for (final image in _selectedImages) {
        final file = File(image.path);
        final fileName = '$DateTime.now().millisecondsSinceEpoch_${image.name}';
        final folderPath = '$userId/$reviewId';

        await client.storage
            .from(bucket.product)
            .upload(
              'reviews/$folderPath/$fileName',
              file,
            );

        await client.from(ProductReviewImageTable().tableName).insert({
          ProductReviewImageRow.uploadedByField: userId,
          ProductReviewImageRow.reviewField: reviewId,
          ProductReviewImageRow.bucketField: bucket.product,
          ProductReviewImageRow.folderPathField: 'reviews/$folderPath',
          ProductReviewImageRow.fileNameField: fileName,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 등록되었습니다.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error submitting review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 등록 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final product = widget.product;
    final productTitle =
        (product?.title ?? product?.name)?.trim() ?? '상품 정보 없음';
    final imageUrl =
        product?.mainImageBucket != null && product?.mainImageFileName != null
        ? getImageLink(
            product!.mainImageBucket!,
            product.mainImageFileName!,
            folderPath: product.mainImageFolderPath,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 작성'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: cs.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                              )
                            : Container(
                                color: cs.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        productTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Rating
            Text(
              '별점',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? Colors.yellow[600] : cs.primary,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // Review text
            Text(
              '리뷰',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLength: 1000,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '상품에 대한 리뷰를 작성해주세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Photos
            Text(
              '사진 (선택)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedImages.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedImages.map((image) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(image.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedImages.remove(image);
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: cs.onError,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: cs.error,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('사진 추가'),
            ),
            const SizedBox(height: 32),
            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('리뷰 등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
