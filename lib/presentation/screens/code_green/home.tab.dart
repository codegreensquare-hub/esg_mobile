import 'package:esg_mobile/core/constants/frame_width.dart';
import 'package:esg_mobile/core/theme/util.dart';
import 'package:esg_mobile/presentation/widgets/home/product_card.widget.dart';
import 'package:esg_mobile/presentation/widgets/home/material_card.widget.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  static const tab = 'home';
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      child: Column(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: frameWidth),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'New In',
                    textAlign: TextAlign.center,
                    style: createTextTheme(context).headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 16,
                          childAspectRatio: 152 / 244,
                        ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        imagePath:
                            'assets/images/product_grid/product_${index + 1}.png',
                        productName: '스퀘어네스트 백',
                      );
                    },
                  ),
                  // "See all" link
                  Text(
                    'See all',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Codegreen Material section
          const SizedBox(height: 85),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: frameWidth),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Heading
                  Text(
                    'Codegreen Material',
                    textAlign: TextAlign.center,
                    style: createTextTheme(context).headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Text(
                      '코드그린은 조금이라도 더 나은 친환경 소재를 위해 끊임없이 찾고, 연구합니다.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Material cards
                  Column(
                    children: [
                      MaterialCard(
                        imagePath:
                            'assets/images/material_grid/material_grid_1.png',
                        koreanTitle: '천연',
                        englishTitle: 'nature-oriented',
                        buttonText: '천연 제품 보러가기',
                        onButtonPressed: () {
                          // TODO: Navigate to nature-oriented products
                        },
                      ),
                      const SizedBox(height: 16),
                      MaterialCard(
                        imagePath:
                            'assets/images/material_grid/material_grid_2.png',
                        koreanTitle: '비건',
                        englishTitle: 'Vegan',
                        buttonText: '비건 제품 보러가기',
                        onButtonPressed: () {
                          // TODO: Navigate to vegan products
                        },
                      ),
                      const SizedBox(height: 16),
                      MaterialCard(
                        imagePath:
                            'assets/images/material_grid/material_grid_3.png',
                        koreanTitle: '생분해',
                        englishTitle: 'biodegradable',
                        buttonText: '생분해 제품 보러가기',
                        onButtonPressed: () {
                          // TODO: Navigate to biodegradable products
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
