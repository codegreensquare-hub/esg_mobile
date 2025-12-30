import 'dart:async';

import 'package:flutter/material.dart';

class CodegreenBannerCarousel extends StatefulWidget {
  const CodegreenBannerCarousel({
    super.key,
    this.imagePaths = const [
      'assets/images/banner/banner1_window.089ff4ec.jpg',
      'assets/images/banner/banner2_window.8e953a16.jpg',
      'assets/images/banner/banner3_window.3c6c17a8.jpg',
    ],
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  final List<String> imagePaths;
  final bool autoPlay;
  final Duration autoPlayInterval;

  @override
  State<CodegreenBannerCarousel> createState() =>
      _CodegreenBannerCarouselState();
}

class _CodegreenBannerCarouselState extends State<CodegreenBannerCarousel> {
  late final PageController _controller;
  int _index = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();

    if (widget.autoPlay) {
      _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
        if (!mounted) return;
        if (widget.imagePaths.length <= 1) return;
        if (!_controller.hasClients) return;

        final nextIndex = (_index + 1) % widget.imagePaths.length;
        _goTo(nextIndex);
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.imagePaths.length) return;
    _controller.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 600;

        final theme = Theme.of(context);

        final bool canGoLeft = _index > 0;
        final bool canGoRight = _index < widget.imagePaths.length - 1;

        final smallHeight = width;

        final pageView = PageView.builder(
          controller: _controller,
          itemCount: widget.imagePaths.length,
          onPageChanged: (value) => setState(() => _index = value),
          itemBuilder: (context, index) {
            final imagePath = widget.imagePaths[index];
            return Image.asset(imagePath, fit: BoxFit.cover);
          },
        );

        final banner = isSmall
            ? SizedBox(
                width: double.infinity,
                height: smallHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [pageView],
                ),
              )
            : AspectRatio(
                aspectRatio: 16 / 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    pageView,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: IconButton.filledTonal(
                          onPressed: canGoLeft ? () => _goTo(_index - 1) : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: IconButton.filledTonal(
                          onPressed: canGoRight
                              ? () => _goTo(_index + 1)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ),
                    ),
                  ],
                ),
              );

        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              banner,
              if (isSmall)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.imagePaths.asMap().keys.map(
                      (i) {
                        final bool isActive = i == _index;
                        return InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _goTo(i),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? theme.colorScheme.onSurface.withValues(
                                        alpha: 0.9,
                                      )
                                    : theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
