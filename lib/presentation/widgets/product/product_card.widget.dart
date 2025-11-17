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
          Expanded(
            flex: 32,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                productName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
