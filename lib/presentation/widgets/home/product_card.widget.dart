import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String productName;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.imagePath,
    required this.productName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Maintain aspect ratio: 152/244
    const double aspectRatio = 152 / 244;
    // Image takes 202/244 of the height, text takes 42/244

    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image container: takes 202/244 of the card height
            Expanded(
              flex: 202,
              child: SizedBox(
                width: double.infinity,
                child: isNetworkImage
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
              ),
            ),
            SizedBox(height: 12), // spacing between image and text
            // Text container: takes 42/244 of the card height
            Text(
              productName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       AspectRatio(
  //         aspectRatio: 152 / 202,
  //         child: Image.asset(imagePath, fit: BoxFit.cover),
  //       ),

  //       SizedBox(height: 6), // you control the spacing

  //       Text(
  //         productName,
  //         textAlign: TextAlign.center,
  //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //           height: 1.0, // removes extra text padding
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
