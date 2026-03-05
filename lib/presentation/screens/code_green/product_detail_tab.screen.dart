import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/data/entities/cart_item_with_product.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/auth/login.dialog.dart';
import 'package:esg_mobile/presentation/widgets/code_green/cart/cart_bottom_sheet.dart';
import 'package:esg_mobile/presentation/widgets/code_green/product_qna_section.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  List<ProductOptionColorRow> _colorOptions = const [];
  String? _selectedColorId;
  String? _selectedColorHex;
  String? _selectedColorImageUrl;

  Map<String, String> _selectedOptions = const {};

  String? _userId;
  int _quantity = 1;
  bool _isAddingToCart = false;
  CartItemWithProduct? _matchingCartItem;
  bool _isCheckingCartState = false;
  int _qnaCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _userId = Supabase.instance.client.auth.currentUser?.id;
    _loadColors();
    _loadQnaCount();
  }

  Future<void> _loadQnaCount() async {
    try {
      final count = await ProductService.instance.getProductQnaCount(
        widget.productWithDetails.product.id,
      );
      if (!mounted) return;
      setState(() => _qnaCount = count);
    } catch (e) {
      debugPrint('Error loading QnA count: $e');
    }
  }

  @override
  void didUpdateWidget(covariant CodeGreenProductDetailTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productWithDetails.product.id !=
        widget.productWithDetails.product.id) {
      _colorOptions = const [];
      _selectedColorId = null;
      _selectedColorHex = null;
      _selectedColorImageUrl = null;
      _selectedOptions = const {};
      _matchingCartItem = null;
      _loadColors();
      _loadQnaCount();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _increaseQuantity() {
    setState(() {
      _quantity = (_quantity + 1).clamp(1, 999).toInt();
    });
  }

  void _decreaseQuantity() {
    if (_quantity <= 1) {
      return;
    }
    setState(() => _quantity -= 1);
  }

  Future<void> _addToCart() async {
    final messenger = ScaffoldMessenger.of(context);

    final userId = _userId;
    if (userId == null || userId.trim().isEmpty) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoginDialog(),
      );
      return;
    }

    if (_colorOptions.isNotEmpty && (_selectedColorHex ?? '').trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('색상을 선택해주세요.')),
      );
      return;
    }

    setState(() => _isAddingToCart = true);
    try {
      final productId = widget.productWithDetails.product.id;

      final selectedColor = (_selectedColorId ?? '').trim();
      final selectedOptions = <String, String>{
        ..._selectedOptions,
        if (selectedColor.isNotEmpty) 'Color': selectedColor,
      };

      final result = await CartService.instance.addItem(
        userId: userId,
        productId: productId,
        quantity: _quantity.toDouble(),
        selectedOptions: selectedOptions,
      );

      if (!mounted) return;

      if (result == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('장바구니 담기에 실패했습니다. 다시 시도해주세요.')),
        );
        return;
      }

      messenger.showSnackBar(
        const SnackBar(content: Text('장바구니에 담았습니다.')),
      );

      await _refreshCartMatch();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            kDebugMode ? '장바구니 담기 중 오류가 발생했습니다.\n$e' : '장바구니 담기 중 오류가 발생했습니다.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  Future<void> _loadColors() async {
    final pid = widget.productWithDetails.product.id.trim();
    if (pid.isEmpty) return;

    final colors = await CartService.instance.fetchColorOptionValues(
      productId: pid,
    );
    if (!mounted) return;
    setState(() => _colorOptions = colors);
    await _refreshCartMatch();
  }

  String _optionsSignatureFromMap(Map<String, String> selectedOptions) {
    final normalized =
        selectedOptions.entries
            .where(
              (e) =>
                  e.key.isNotEmpty &&
                  e.value.isNotEmpty &&
                  e.key.toLowerCase() != 'color',
            )
            .map((e) => '${e.key}=${e.value}')
            .toList(growable: false)
          ..sort();
    return normalized.join('|');
  }

  String _cartItemOptionsSignature(List<CartItemOptionRow> options) {
    final normalized =
        options
            .where(
              (o) => (o.option ?? '').isNotEmpty && (o.value ?? '').isNotEmpty,
            )
            .where((o) => (o.option ?? '').toLowerCase() != 'color')
            .map((o) => '${o.option}=${o.value}')
            .toList(growable: false)
          ..sort();
    return normalized.join('|');
  }

  String _cartItemSelectedColor(CartItemWithProduct item) {
    final fromField = (item.cartItem.optionColor ?? '').trim();
    if (fromField.isNotEmpty) return fromField;

    final fromOptions = item.options
        .where((o) => (o.option ?? '').toLowerCase() == 'color')
        .map((o) => (o.value ?? '').trim())
        .where((v) => v.isNotEmpty)
        .toList(growable: false);

    return fromOptions.isEmpty ? '' : fromOptions.first;
  }

  Future<void> _refreshCartMatch() async {
    final userId = _userId;
    if (userId == null || userId.trim().isEmpty) {
      if (!mounted) return;
      setState(() => _matchingCartItem = null);
      return;
    }

    final requiresColorSelection = _colorOptions.isNotEmpty;
    final selectedColorId = (_selectedColorId ?? '').trim();
    if (requiresColorSelection && selectedColorId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _matchingCartItem = null;
        _isCheckingCartState = false;
      });
      return;
    }

    final selectedColorHex = (_selectedColorHex ?? '').trim();

    final selectedOptions = <String, String>{
      ..._selectedOptions,
      if (selectedColorId.isNotEmpty) 'Color': selectedColorId,
    };
    final requestedSignature = _optionsSignatureFromMap(selectedOptions);
    final productId = widget.productWithDetails.product.id;

    if (!mounted) return;
    setState(() => _isCheckingCartState = true);

    final items = await CartService.instance.fetchCartItems(userId);
    if (!mounted) return;

    final match = items
        .where((e) => e.product.id == productId)
        .map(
          (e) => (
            item: e,
            signature: _cartItemOptionsSignature(e.options),
            color: _cartItemSelectedColor(e).toLowerCase(),
          ),
        )
        .where(
          (e) =>
              e.signature == requestedSignature &&
              (e.color == selectedColorId.toLowerCase() ||
                  (selectedColorHex.isNotEmpty &&
                      e.color == selectedColorHex.toLowerCase())),
        )
        .map((e) => e.item)
        .toList(growable: false);

    setState(() {
      _matchingCartItem = match.isEmpty ? null : match.first;
      _isCheckingCartState = false;
    });
  }

  Future<void> _openCart() async {
    final userId = _userId;
    if (userId == null || userId.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final items = await CartService.instance.fetchCartItems(userId);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CodeGreenCartBottomSheet(items: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final requiresColorSelection = _colorOptions.isNotEmpty;
    final hasSelectedColor = (_selectedColorId ?? '').trim().isNotEmpty;
    final canAddToCart = !requiresColorSelection || hasSelectedColor;

    final productWithDetails = widget.productWithDetails;
    final product = productWithDetails.product;
    final title = (product.title ?? product.name ?? '').isNotEmpty
        ? (product.title ?? product.name!)
        : 'Product';
    final sellerName = productWithDetails.seller.username ?? 'Unknown Seller';
    final description = product.description;

    final baseMainImageUrl =
        product.mainImageBucket != null && product.mainImageFileName != null
        ? getImageLink(
            product.mainImageBucket!,
            product.mainImageFileName!,
            folderPath: product.mainImageFolderPath,
          )
        : null;

    final mainImageUrl = _selectedColorImageUrl ?? baseMainImageUrl;

    final otherImageUrls = productWithDetails.images
        .where((row) => row.bucket != null && row.fileName != null)
        .map(
          (row) => getImageLink(
            row.bucket!,
            row.fileName!,
            folderPath: row.folderPath,
          ),
        )
        .where((url) => url != mainImageUrl)
        .toList(growable: false);

    final galleryUrls = <String>[
      if (mainImageUrl != null) mainImageUrl,
      ...otherImageUrls,
    ];

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
            if (_colorOptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Color',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions
                    .where((row) => (row.value ?? '').trim().length == 6)
                    .map((row) {
                      final hex = (row.value ?? '').trim();
                      final isSelected =
                          (_selectedColorId ?? '').toLowerCase() ==
                          row.id.toLowerCase();

                      final color = Color(int.parse('FF$hex', radix: 16));

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            final bucket = row.coloredProductBucket;
                            final fileName = row.coloredProductFileName;
                            final folderPath = row.coloredProductFolderPath;

                            final nextUrl = bucket != null && fileName != null
                                ? getImageLink(
                                    bucket,
                                    fileName,
                                    folderPath: folderPath,
                                  )
                                : null;

                            setState(() {
                              _selectedColorId = row.id;
                              _selectedColorHex = hex;
                              _selectedColorImageUrl = nextUrl;
                              _selectedImageIndex = 0;
                            });

                            _refreshCartMatch();

                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                            );
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: isSelected
                                    ? cs.primary
                                    : cs.outlineVariant,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ],

            const SizedBox(height: 16),
            Text(
              '수량',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _decreaseQuantity,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$_quantity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: _increaseQuantity,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _matchingCartItem == null
                  ? ElevatedButton(
                      onPressed: (!canAddToCart || _isAddingToCart)
                          ? null
                          : _addToCart,
                      child: _isAddingToCart
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Add to cart'),
                              ],
                            ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isCheckingCartState
                              ? 'Checking cart...'
                              : 'Already added to cart.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isAddingToCart ? null : _addToCart,
                                child: _isAddingToCart
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Add another'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _openCart,
                                child: const Text('Check cart'),
                              ),
                            ),
                          ],
                        ),
                      ],
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
        Tab(text: 'QnA($_qnaCount)'),
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
      child: ProductQnaSection(productId: product.id),
    );

    if (widget.embedded) {
      return DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
        extendBodyBehindAppBar: widget.showAppBar,
        appBar: widget.showAppBar
            ? AppBar(
                backgroundColor: cs.surface.withValues(alpha: 0.85),
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
