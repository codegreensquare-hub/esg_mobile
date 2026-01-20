import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';

class ReviewImagesFullscreen extends StatelessWidget {
  const ReviewImagesFullscreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  final List<ProductReviewImageRow> images;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];
          final url = getImageLink(
            image.bucket ?? '',
            image.fileName ?? '',
            folderPath: image.folderPath,
          );
          return Hero(
            tag: 'review-image-${image.id}',
            child: InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.image_not_supported, size: 64),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
