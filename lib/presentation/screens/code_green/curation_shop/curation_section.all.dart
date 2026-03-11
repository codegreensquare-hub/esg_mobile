import 'package:flutter/material.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'curation_shop.product_fetch.dart';

class CurationSectionAll extends StatelessWidget {
  const CurationSectionAll({super.key, this.onTapProduct});

  final ValueChanged<ProductWithOtherDetails>? onTapProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '소싱이나 협업으로 만든 가방에 \ncode green 의 가치와 솔루션을 추가한 라인입니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: const Color(0xFF979797),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        CurationShopProductFetch(
          tab: 'all',
          onTapProduct: onTapProduct,
          isCuration: true,
        ),
      ],
    );
  }
}
