import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/presentation/screens/code_green/widgets/home_products_grid.widget.dart';
import 'package:flutter/material.dart';

class HomeNewInProducts extends StatelessWidget {
  const HomeNewInProducts({
    required this.isLoading,
    required this.error,
    required this.products,
    required this.resolveImagePath,
    required this.resolveTitle,
    super.key,
  });

  final bool isLoading;
  final String? error;
  final List<ProductWithOtherDetails> products;
  final String Function(ProductWithOtherDetails item) resolveImagePath;
  final String Function(ProductWithOtherDetails item) resolveTitle;

  @override
  Widget build(BuildContext context) {
    final content = switch ((isLoading, error, products.isEmpty)) {
      (true, _, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      (false, final err?, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text(err)),
      ),
      (false, null, true) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No products found.')),
      ),
      _ => HomeProductsGrid(
        products: products,
        resolveImagePath: resolveImagePath,
        resolveTitle: resolveTitle,
      ),
    };

    return Column(
      children: [
        content,
        SizedBox(height: 16),
        Text(
          'See all',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
