import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:flutter/material.dart';

class CodeGreenProductDetailTabScreen extends StatefulWidget {
  const CodeGreenProductDetailTabScreen({
    super.key,
    required this.productWithDetails,
    this.reviewCount = 0,
    this.qnaCount = 0,
    this.showAppBar = true,
    this.embedded = false,
    this.onBack,
  });

  final ProductWithOtherDetails productWithDetails;
  final int reviewCount;
  final int qnaCount;
  final bool showAppBar;
  final bool embedded;
  final VoidCallback? onBack;

  @override
  State<CodeGreenProductDetailTabScreen> createState() =>
      _CodeGreenProductDetailTabScreenState();
}

class _CodeGreenProductDetailTabScreenState
    extends State<CodeGreenProductDetailTabScreen> {
  late final PageController _pageController;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final productWithDetails = widget.productWithDetails;
    final product = productWithDetails.product;
    final title = (product.title ?? product.name ?? '').isNotEmpty
        ? (product.title ?? product.name!)
        : 'Product';
    final sellerName = productWithDetails.seller.username ?? 'Unknown Seller';
    final description = product.description;

    final mainImageUrl =
        product.mainImageBucket != null && product.mainImageFileName != null
        ? getImageLink(
            product.mainImageBucket!,
            product.mainImageFileName!,
            folderPath: product.mainImageFolderPath,
          )
        : null;

    final galleryUrls = <String>{
      ...productWithDetails.images
          .where((row) => row.bucket != null && row.fileName != null)
          .map(
            (row) => getImageLink(
              row.bucket!,
              row.fileName!,
              folderPath: row.folderPath,
            ),
          ),
      if (mainImageUrl != null) mainImageUrl,
    }.toList(growable: false);

    final price = product.regularPrice;

    final safeSelectedIndex = _selectedImageIndex.clamp(
      0,
      (galleryUrls.isEmpty ? 1 : galleryUrls.length) - 1,
    );

    final header = LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final gallery = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (galleryUrls.isNotEmpty)
                      PageView.builder(
                        controller: _pageController,
                        itemCount: galleryUrls.length,
                        onPageChanged: (index) =>
                            setState(() => _selectedImageIndex = index),
                        itemBuilder: (context, index) {
                          final url = galleryUrls[index];
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: cs.surfaceContainerHighest,
                                alignment: Alignment.center,
                                child:
                                    const CircularProgressIndicator.adaptive(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: cs.surfaceContainerHighest,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          );
                        },
                      )
                    else
                      Container(
                        color: cs.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image),
                      ),
                    if (widget.embedded && widget.onBack != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Material(
                          color: cs.surface.withValues(alpha: 0.9),
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Back',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (galleryUrls.length > 1) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: galleryUrls.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = index == safeSelectedIndex;
                    return InkWell(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        );
                        setState(() => _selectedImageIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? cs.primary : cs.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          galleryUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: cs.surfaceContainerHighest,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_not_supported),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );

        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '[$sellerName]',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if ((productWithDetails.categoryName ?? '').isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      productWithDetails.categoryName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              price != null ? formatKRW(price) : 'Price on request',
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
                maxLines: isWide ? 8 : 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: gallery),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: details),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gallery,
            const SizedBox(height: 16),
            details,
          ],
        );
      },
    );

    final tabBar = TabBar(
      dividerColor: cs.outlineVariant,
      tabs: [
        const Tab(text: 'Detail'),
        Tab(text: 'Review(${widget.reviewCount})'),
        Tab(text: 'QnA(${widget.qnaCount})'),
      ],
    );

    final detailContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            (description != null && description.isNotEmpty)
                ? description
                : 'No description provided.',
            style: theme.textTheme.bodyMedium,
          ),
          if ((product.name ?? '').isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Product name',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );

    final reviewContent = Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Reviews are coming soon.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );

    final qnaContent = Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'QnA is coming soon.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: header,
            ),
            tabBar,
            Builder(
              builder: (context) {
                final controller = DefaultTabController.of(context);
                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    return switch (controller.index) {
                      0 => detailContent,
                      1 => reviewContent,
                      _ => qnaContent,
                    };
                  },
                );
              },
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: header,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarHeaderDelegate(
                  tabBar: tabBar,
                  backgroundColor: cs.surface,
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: detailContent,
              ),
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: reviewContent,
              ),
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: qnaContent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabBarHeaderDelegate({
    required this.tabBar,
    required this.backgroundColor,
  });

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
