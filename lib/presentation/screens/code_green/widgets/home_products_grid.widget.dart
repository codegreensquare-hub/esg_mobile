import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/presentation/screens/code_green/product_detail_tab.screen.dart';
import 'package:esg_mobile/presentation/widgets/home/product_card.widget.dart';
import 'package:flutter/material.dart';

class HomeProductsGrid extends StatelessWidget {
  const HomeProductsGrid({
    required this.products,
    required this.resolveImagePath,
    required this.resolveTitle,
    this.onTapProduct,
    super.key,
  });

  final List<ProductWithOtherDetails> products;
  final String Function(ProductWithOtherDetails item) resolveImagePath;
  final String Function(ProductWithOtherDetails item) resolveTitle;
  final ValueChanged<ProductWithOtherDetails>? onTapProduct;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final crossAxisCount = switch (width) {
          >= 900 => 4,
          >= 600 => 3,
          _ => 2,
        };

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 16,
            childAspectRatio: 152 / 244,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              imagePath: resolveImagePath(product),
              productName: resolveTitle(product),
              productId: product.product.id,
              mainImageFolderPath: product.product.mainImageFolderPath,
              onTap: () {
                final handler = onTapProduct;
                if (handler != null) {
                  handler(product);
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CodeGreenProductDetailTabScreen(
                      productWithDetails: product,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
