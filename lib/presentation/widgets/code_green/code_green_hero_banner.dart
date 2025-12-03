import 'dart:math' as math;

import 'package:esg_mobile/core/constants/frame_width.dart';
import 'package:esg_mobile/core/enums/device.dart';
import 'package:esg_mobile/presentation/widgets/main/fade_carousel.container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeGreenHeroBanner extends StatefulWidget {
  const CodeGreenHeroBanner({
    super.key,
    this.onAboutUsPressed,
  });

  final void Function()? onAboutUsPressed;

  @override
  State<CodeGreenHeroBanner> createState() => _CodeGreenHeroBannerState();
}

class _CodeGreenHeroBannerState extends State<CodeGreenHeroBanner> {
  List<String> _carouselAssets = const [];

  @override
  void initState() {
    super.initState();
    _loadCarouselAssets();
  }

  Future<void> _loadCarouselAssets() async {
    const potentialAssets = [
      'assets/images/carousel/carousel_1.jpg',
      'assets/images/carousel/carousel_2.jpg',
      'assets/images/carousel/carousel_4.jpg',
      'assets/images/carousel/carousel_5.jpg',
    ];

    final verifiedAssets = <String>[];
    for (final asset in potentialAssets) {
      try {
        await rootBundle.load(asset);
        verifiedAssets.add(asset);
      } catch (_) {
        // Skip missing asset
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

    return FadeCarouselContainer.assets(
      _carouselAssets,
      height: carouselHeight,
      switchInterval: const Duration(seconds: 5),
      overlayColor: Colors.black.withAlpha(89),
      alignment: const Alignment(0, -0.5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: frameWidth),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            defaultPadding * 3,
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
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '자연에 기여하는 길을 찾습니다.',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
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
                  padding: EdgeInsets.symmetric(
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
    );
  }
}
