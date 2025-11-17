import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String productName;

  const ProductCard({
    super.key,
    required this.imagePath,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    // Maintain aspect ratio: 152/244
    const double aspectRatio = 152 / 244;
    // Image takes 202/244 of the height, text takes 42/244

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image container: takes 202/244 of the card height
          Expanded(
            flex: 202,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
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
          // Text container: takes 42/244 of the card height
          Text(
            productName,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
          ),
        ],
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
