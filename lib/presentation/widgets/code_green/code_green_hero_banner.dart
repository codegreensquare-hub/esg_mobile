import 'dart:math' as math;

import 'package:esg_mobile/core/constants/asset.dart' as asset_constants;
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/constants/frame_width.dart';
import 'package:esg_mobile/core/enums/device.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/presentation/widgets/main/fade_carousel.container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  late final List<String> _carouselAssets;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _carouselAssets = [
      getImageLink(
        bucket.asset,
        asset_constants.asset.carousel1,
        folderPath:
            asset_constants.assetFolderPath[asset_constants.asset.carousel1],
      ),
      getImageLink(
        bucket.asset,
        asset_constants.asset.carousel2,
        folderPath:
            asset_constants.assetFolderPath[asset_constants.asset.carousel2],
      ),
      getImageLink(
        bucket.asset,
        asset_constants.asset.carousel3,
        folderPath:
            asset_constants.assetFolderPath[asset_constants.asset.carousel3],
      ),
      getImageLink(
        bucket.asset,
        asset_constants.asset.carousel4,
        folderPath:
            asset_constants.assetFolderPath[asset_constants.asset.carousel4],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < Device.smallTablet.breakpoint;
    final double carouselHeight = isSmall ? 445 : math.min(width / 3, 700);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeCarouselContainer.network(
          _carouselAssets,
          height: carouselHeight,
          switchInterval: const Duration(seconds: 5),
          overlayColor: Colors.black.withAlpha(89),
          alignment: const Alignment(0, -0.5),
          forcedIndex: _currentIndex,
          onIndexChanged: (index) {
            if (!mounted) return;
            setState(() => _currentIndex = index);
          },
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
                    onPressed: widget.onAboutUsPressed,
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
        ),
        if (_carouselAssets.length > 1) ...[
          Container(
            color: const Color(0xFFFDF8F7),
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_carouselAssets.length, (index) {
                final isActive = index == _currentIndex;
                return GestureDetector(
                  onTap: () {
                    if (!mounted) return;
                    setState(() => _currentIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 10 : 8,
                    height: isActive ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF000000)
                          : const Color(0xFFC7C7CC),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}
