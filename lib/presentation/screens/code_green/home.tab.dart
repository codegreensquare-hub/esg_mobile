import 'dart:math' as math;
import 'package:esg_mobile/core/constants/frame_width.dart';
import 'package:esg_mobile/presentation/widgets/main/fade_carousel.container.dart';
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
          Center(
            child: Text(
              'Code Green Home Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}
