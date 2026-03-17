import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/services/database/featured_product_banner.service.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/code_green/product_detail_tab.screen.dart';
import 'package:flutter/material.dart';

class CodegreenBannerCarousel extends StatefulWidget {
  const CodegreenBannerCarousel({
    super.key,
    required this.appType,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  final String appType;
  final bool autoPlay;
  final Duration autoPlayInterval;

  @override
  State<CodegreenBannerCarousel> createState() =>
      _CodegreenBannerCarouselState();
}

class _CodegreenBannerCarouselState extends State<CodegreenBannerCarousel> {
  late final PageController _controller;
  int _index = 0;
  List<_FeaturedBannerItem>? _items;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    debugPrint(
      '[CodegreenBannerCarousel] Loading featured banners for appType=${widget.appType}',
    );

    final banners = await FeaturedProductBannerService.instance
        .fetchActiveBanners(
          appType: widget.appType,
        );

    debugPrint(
      '[CodegreenBannerCarousel] Fetched ${banners.length} featured_product_banner rows',
    );

    if (!mounted || banners.isEmpty) {
      if (mounted) {
        setState(() => _items = const []);
      }
      return;
    }

    final productIds = banners
        .map((b) => b.productId)
        .where((id) => id.trim().isNotEmpty)
        .toList();

    debugPrint(
      '[CodegreenBannerCarousel] Product IDs from banners: $productIds',
    );

    final products = await ProductService.instance.fetchProductsByIds(
      productIds: productIds,
    );

    debugPrint(
      '[CodegreenBannerCarousel] Loaded ${products.length} products for featured banners',
    );

    if (!mounted) return;

    final productById = {
      for (final p in products) p.product.id: p,
    };

    final items = banners
        .where((b) {
          final hasProduct = productById[b.productId] != null;
          if (!hasProduct) {
            debugPrint(
              '[CodegreenBannerCarousel] Skipping banner ${b.id} because product ${b.productId} was not found',
            );
          }
          return hasProduct;
        })
        .map((b) {
          final product = productById[b.productId]!;

          String? backgroundUrl;

          if ((b.backgroundImageBucket ?? '').isNotEmpty &&
              (b.backgroundImageFileName ?? '').isNotEmpty) {
            backgroundUrl = getImageLink(
              b.backgroundImageBucket!,
              b.backgroundImageFileName!,
              folderPath: b.backgroundImageFolderPath,
            );
          } else if ((product.product.mainImageBucket ?? '').isNotEmpty &&
              (product.product.mainImageFileName ?? '').isNotEmpty) {
            backgroundUrl = getImageLink(
              product.product.mainImageBucket!,
              product.product.mainImageFileName!,
              folderPath: product.product.mainImageFolderPath,
            );
          }

          debugPrint(
            '[CodegreenBannerCarousel] Banner ${b.id} for product ${product.product.id} -> backgroundUrl=${backgroundUrl ?? '(none)'}',
          );

          return _FeaturedBannerItem(
            banner: b,
            product: product,
            backgroundImageUrl: backgroundUrl,
          );
        })
        .toList(growable: false);

    setState(() {
      _items = items;
      _index = 0;
    });

    if (widget.autoPlay && items.length > 1) {
      _autoPlayTimer?.cancel();
      _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
        if (!mounted) return;
        if (!_controller.hasClients) return;
        if (_items == null || _items!.length <= 1) return;

        final nextIndex = (_index + 1) % _items!.length;
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
    final items = _items;
    if (items == null) return;
    if (newIndex < 0 || newIndex >= items.length) return;
    _controller.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    if (items == null) {
      return const SizedBox.shrink();
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 600;

        final theme = Theme.of(context);

        final bool canGoLeft = _index > 0;
        final bool canGoRight = _index < items.length - 1;

        final smallHeight = width;

        final pageView = PageView.builder(
          controller: _controller,
          itemCount: items.length,
          onPageChanged: (value) => setState(() => _index = value),
          itemBuilder: (context, index) {
            final item = items[index];
            return _FeaturedBannerCard(
              item: item,
            );
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
                    children: items.asMap().keys.map(
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

class _FeaturedBannerItem {
  const _FeaturedBannerItem({
    required this.banner,
    required this.product,
    required this.backgroundImageUrl,
  });

  final FeaturedProductBannerRow banner;
  final ProductWithOtherDetails product;
  final String? backgroundImageUrl;
}

class _FeaturedBannerCard extends StatelessWidget {
  const _FeaturedBannerCard({
    required this.item,
  });

  final _FeaturedBannerItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final backgroundUrl = item.backgroundImageUrl;
    final title = item.banner.title ?? '';
    final subtitle = item.banner.subtitle ?? '';
    final buttonText = (item.banner.buttonText ?? 'View product').trim();

    Widget background;
    if (backgroundUrl != null && backgroundUrl.isNotEmpty) {
      background = CachedNetworkImage(
        imageUrl: backgroundUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: cs.surfaceContainerHighest,
        ),
        errorWidget: (context, url, error) => Container(
          color: cs.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported),
        ),
      );
    } else {
      background = Container(
        color: cs.surfaceContainerHighest,
      );
    }

    void openProductDetail() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CodeGreenProductDetailTabScreen(
            productWithDetails: item.product,
          ),
        ),
      );
    }

    return InkWell(
      onTap: openProductDetail,
      child: Stack(
        fit: StackFit.expand,
        children: [
          background,
          Container(
            color: Colors.black.withValues(alpha: 0.05),
          ),
          Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 320,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.9),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (title.isNotEmpty) ...[
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (subtitle.isNotEmpty) ...[
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    TextButton(
                      onPressed: openProductDetail,
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurface,
                      ),
                      child: Text(
                        buttonText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
