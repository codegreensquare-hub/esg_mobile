import 'dart:math' as math;
import 'package:esg_mobile/core/constants/frame_width.dart';
import 'package:esg_mobile/core/theme/util.dart';
import 'package:esg_mobile/presentation/widgets/main/fade_carousel.container.dart';
import 'package:esg_mobile/presentation/widgets/home/product_card.widget.dart';
import 'package:esg_mobile/presentation/widgets/home/material_card.widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esg_mobile/core/enums/device.dart';

class HomeTab extends StatefulWidget {
  static const tab = 'home';
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<String> _carouselAssets = const [];

  // @override
  // void initState() {
  //   super.initState();
  //   _loadCarouselAssets();
  // }

  // Future<void> _loadCarouselAssets() async {
  //   try {
  //     final manifestJson = await rootBundle.loadString('AssetManifest.json');
  //     final Map<String, dynamic> manifest =``
  //         (jsonDecode(manifestJson) as Map<String, dynamic>);
  //     final assets =
  //         manifest.keys
  //             .where((k) => k.startsWith('assets/images/carousel/'))
  //             .toList()
  //           ..sort();
  //     if (!mounted) return;
  //     setState(() => _carouselAssets = assets);
  //   } catch (_) {
  //     // If manifest is unavailable or empty, leave list empty.
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadCarouselAssets();
  }

  Future<void> _loadCarouselAssets() async {
    // Predefined list of carousel assets
    const potentialAssets = [
      'assets/images/carousel/carousel_1.jpg',
      'assets/images/carousel/carousel_2.jpg',
      'assets/images/carousel/carousel_4.jpg',
      'assets/images/carousel/carousel_5.jpg',
    ];

    // Verify each asset exists by trying to load it
    final verifiedAssets = <String>[];
    for (final asset in potentialAssets) {
      try {
        await rootBundle.load(asset);
        verifiedAssets.add(asset);
      } catch (_) {
        // Asset doesn't exist or can't be loaded, skip it
      }
    }

    if (!mounted) return;
    setState(() => _carouselAssets = verifiedAssets);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < Device.smallTablet.breakpoint;
    final double carouselHeight = isSmall ? 445 : math.min(width / 3, 700);
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      child: Column(
        children: [
          // Carousel or banner can be added here
          FadeCarouselContainer.assets(
            _carouselAssets,
            height: carouselHeight,
            switchInterval: const Duration(seconds: 5),
            overlayColor: Colors.black.withAlpha(89),
            alignment: Alignment(0, -0.5),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: frameWidth),
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  defaultPadding * 3,
                  // if not web, 0
                  // if web, defaultPadding
                  0,
                  defaultPadding * 3,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      '코드그린은 일상을 만끽하며',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '자연에 기여하는 길을 찾습니다.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 52),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to About Us page/route
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: kIsWeb ? 48 : 40,
                          vertical: kIsWeb ? 22 : 14,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'About Us',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // New In section
          const SizedBox(height: 54),
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
