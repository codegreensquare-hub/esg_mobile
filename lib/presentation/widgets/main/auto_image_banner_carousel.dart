import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/services/database/banner.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:flutter/material.dart';

class AutoImageBannerCarousel extends StatefulWidget {
  const AutoImageBannerCarousel({
    super.key,
    required this.assetImagePaths,
    this.height = 160,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.isNetwork = false,
  }) : assert(assetImagePaths.length > 0, 'assetImagePaths cannot be empty');

  final List<String> assetImagePaths;
  final double height;
  final Duration autoPlayInterval;
  final bool isNetwork;

  @override
  State<AutoImageBannerCarousel> createState() =>
      _AutoImageBannerCarouselState();
}

class _AutoImageBannerCarouselState extends State<AutoImageBannerCarousel> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  static const _infiniteItemCount = 3000;
  static const _initialPage = 1500;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(
      widget.autoPlayInterval,
      (_) {
        if (!mounted) return;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant AutoImageBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePaths = widget.assetImagePaths;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(
                    () => _currentIndex = index % imagePaths.length,
                  );
                },
                itemCount: _infiniteItemCount,
                itemBuilder: (context, index) {
                  final assetPath = imagePaths[index % imagePaths.length];
                  return _BannerImage(
                    assetPath: assetPath,
                    isNetwork: widget.isNetwork,
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imagePaths.length, (index) {
                    final isActive = index == _currentIndex;
                    return GestureDetector(
                      onTap: () {
                        final target =
                            _initialPage + index; // Align with infinite pager
                        _pageController.animateToPage(
                          target,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
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
          ),
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage({
    required this.assetPath,
    required this.isNetwork,
  });

  final String assetPath;
  final bool isNetwork;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: isNetwork
          ? CachedNetworkImage(
              imageUrl: assetPath,
              fit: BoxFit.cover,
            )
          : Image.asset(
              assetPath,
              fit: BoxFit.cover,
            ),
    );
  }
}

class SupabaseBannerCarousel extends StatefulWidget {
  const SupabaseBannerCarousel({
    super.key,
    required this.appType,
    this.height = 160,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  final String appType;
  final double height;
  final Duration autoPlayInterval;

  @override
  State<SupabaseBannerCarousel> createState() =>
      _SupabaseBannerCarouselState();
}

class _SupabaseBannerCarouselState extends State<SupabaseBannerCarousel> {
  List<String>? _imageUrls;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    final rows =
        await BannerService.instance.fetchActiveBanners(appType: widget.appType);

    final urls = rows
        .where(
          (row) =>
              row.imageBucket != null &&
              row.imageFileName != null &&
              row.imageBucket!.isNotEmpty &&
              row.imageFileName!.isNotEmpty,
        )
        .map(
          (row) => getImageLink(
            row.imageBucket!,
            row.imageFileName!,
            folderPath: row.imageFolderPath,
          ),
        )
        .toList(growable: false);

    if (!mounted) return;

    setState(() {
      _imageUrls = urls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final urls = _imageUrls;

    // If nothing is fetched (null or empty), don't render the carousel.
    if (urls == null || urls.isEmpty) {
      return const SizedBox.shrink();
    }

    return AutoImageBannerCarousel(
      assetImagePaths: urls,
      height: widget.height,
      autoPlayInterval: widget.autoPlayInterval,
      isNetwork: true,
    );
  }
}


