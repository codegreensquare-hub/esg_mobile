import 'package:esg_mobile/app/app.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/core/utils/product_pricing.dart';
import 'package:esg_mobile/data/entities/product_option_definition.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:esg_mobile/presentation/widgets/green_square/product_action_buttons_bar.dart';
import 'package:esg_mobile/presentation/widgets/green_square/product_description_tab.dart';
import 'package:esg_mobile/presentation/widgets/green_square/reviews_tab.dart';
import 'package:esg_mobile/presentation/widgets/code_green/product_qna_section.widget.dart';
import 'package:esg_mobile/presentation/widgets/green_square/cart/cart_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:esg_mobile/web_updater.dart'
    if (dart.library.html) 'dart:js'
    as js;

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productWithDetails,
  });

  final ProductWithOtherDetails productWithDetails;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late ProductWithOtherDetails productWithDetails;
  bool isInWishlist = false;
  String? userId;
  int quantity = 1;
  bool isAddingToCart = false;
  bool isLoadingOptions = true;
  List<ProductOptionDefinition> productOptions = [];
  List<ProductOptionColorRow> productColors = [];
  final Map<String, String> selectedOptionValues = {};
  String? selectedVariantImageUrl;
  double currentAwardPoints = 0.0;
  double reviewAverage = 0.0;
  int reviewCount = 0;
  int qnaCount = 0;
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _actionButtonsKey = GlobalKey();
  bool _showStickyActions = false;

  @override
  void initState() {
    super.initState();
    productWithDetails = widget.productWithDetails;
    userId = Supabase.instance.client.auth.currentUser?.id;
    isInWishlist = productWithDetails.isInWishlist;
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_handleTabChange);
    _scrollController.addListener(_updateStickyActionsVisibility);
    _loadProductOptions();
    _loadAwardPoints();
    _loadReviewStats();
    _fetchWishlistStatus();
    if (kIsWeb) {
      js.context['history'].callMethod('pushState', [
        null,
        '',
        '/greensquare/store?product=${productWithDetails.product.id}',
      ]);
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateStickyActionsVisibility(),
    );
  }

  void _handleTabChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.removeListener(_updateStickyActionsVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateStickyActionsVisibility() {
    if (!mounted) return;
    final renderBox =
        _actionButtonsKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero);
    final top = position.dy;
    final bottom = top + renderBox.size.height;
    final mediaQuery = MediaQuery.of(context);
    final viewTop = mediaQuery.padding.top + kToolbarHeight;
    final viewBottom = mediaQuery.size.height - mediaQuery.padding.bottom;
    final isVisible = bottom > viewTop && top < viewBottom;
    final shouldShow = !isVisible;
    if (shouldShow == _showStickyActions) return;
    setState(() => _showStickyActions = shouldShow);
  }

  Future<void> _toggleWishlist() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      if (isInWishlist) {
        await ProductService.instance.removeFromWishlist(
          productWithDetails.product.id,
          userId!,
        );
      } else {
        await ProductService.instance.addToWishlist(
          productWithDetails.product.id,
          userId!,
        );
      }

      setState(() {
        isInWishlist = !isInWishlist;
        productWithDetails = ProductWithOtherDetails(
          product: productWithDetails.product,
          seller: productWithDetails.seller,
          categoryName: productWithDetails.categoryName,
          images: productWithDetails.images,
          isInWishlist: isInWishlist,
        );
      });
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('찜하기 처리 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _loadProductOptions() async {
    setState(() => isLoadingOptions = true);
    final options = await CartService.instance.fetchProductOptions(
      productWithDetails.product.id,
    );
    final colorValues = await CartService.instance.fetchColorOptionValues(
      productId: productWithDetails.product.id,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      productOptions = options;
      productColors = colorValues;
      isLoadingOptions = false;
    });
  }

  Future<void> _loadAwardPoints() async {
    if (userId == null) return;
    try {
      currentAwardPoints = await ProductService.instance.getUserAwardPoints(
        userId!,
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading award points: $e');
      currentAwardPoints = 0.0;
    }
  }

  Future<void> _loadReviewStats() async {
    try {
      final average = await ProductService.instance.getProductAverageStars(
        productWithDetails.product.id,
      );
      final count = await ProductService.instance.getProductReviewCount(
        productWithDetails.product.id,
      );
      final qnaCountFetched = await ProductService.instance.getProductQnaCount(
        productWithDetails.product.id,
      );
      if (!mounted) return;
      setState(() {
        reviewAverage = average;
        reviewCount = count;
        qnaCount = qnaCountFetched;
      });
    } catch (e) {
      debugPrint('Error loading review stats: $e');
    }
  }

  Future<void> _fetchWishlistStatus() async {
    if (userId == null) return;
    try {
      final isIn = await ProductService.instance.isProductInWishlist(
        productWithDetails.product.id,
        userId!,
      );
      if (mounted) {
        setState(() => isInWishlist = isIn);
      }
    } catch (e) {
      debugPrint('Error fetching wishlist status: $e');
    }
  }

  void _increaseQuantity() {
    // Inventory/stock is not tracked right now.
    setState(() {
      quantity = (quantity + 1).clamp(1, 999).toInt();
    });
  }

  void _decreaseQuantity() {
    if (quantity == 1) {
      return;
    }
    setState(() => quantity -= 1);
  }

  Future<void> _addToCart() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final hasMissingOption = productOptions.any(
      (option) => (selectedOptionValues[option.id] ?? '').isEmpty,
    );

    final hasMissingColor =
        productColors.isNotEmpty &&
        (selectedOptionValues['__color__'] ?? '').trim().isEmpty;

    if (hasMissingOption || hasMissingColor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 옵션을 선택해주세요.')),
      );
      return;
    }

    setState(() => isAddingToCart = true);
    try {
      final optionPayload = {
        for (final option in productOptions)
          if ((selectedOptionValues[option.id] ?? '').isNotEmpty)
            option.label: selectedOptionValues[option.id]!,
        if ((selectedOptionValues['__color__'] ?? '').trim().isNotEmpty)
          'Color': selectedOptionValues['__color__']!.trim(),
      };

      final result = await CartService.instance.addItem(
        userId: userId!,
        productId: productWithDetails.product.id,
        quantity: quantity.toDouble(),
        selectedOptions: optionPayload,
      );

      if (!mounted) {
        return;
      }

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('장바구니 담기에 실패했습니다. 다시 시도해주세요.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장바구니에 담았습니다.')),
      );
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장바구니 담기 중 오류가 발생했습니다.')),
      );
    } finally {
      if (mounted) {
        setState(() => isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final product = productWithDetails.product;
    final imageUrl =
        product.mainImageBucket != null && product.mainImageFileName != null
        ? getImageLink(
            product.mainImageBucket!,
            product.mainImageFileName!,
            folderPath: product.mainImageFolderPath,
          )
        : null;
    final resolvedImageUrl = selectedVariantImageUrl ?? imageUrl;
    final double? regularPrice = product.regularPrice;
    final baseDiscountRate = product.baseDiscountRate ?? 0.0;
    final platformDiscountRate = product.platformDiscountRate ?? 0.0;
    final vendorDiscountRate = product.vendorDiscountRate ?? 0.0;
    final double totalDiscountRate =
        baseDiscountRate + platformDiscountRate + vendorDiscountRate;
    final int? usableAwardPoints = regularPrice == null
        ? null
        : usableAwardPointsAmount(
            regularPrice: regularPrice,
            baseDiscountRate: baseDiscountRate,
            platformDiscountRate: platformDiscountRate,
            vendorDiscountRate: vendorDiscountRate,
          );
    final int? discountedPrice = regularPrice == null
        ? null
        : minimumPriceAmount(
            regularPrice: regularPrice,
            baseDiscountRate: baseDiscountRate,
            platformDiscountRate: platformDiscountRate,
            vendorDiscountRate: vendorDiscountRate,
          );
    final hasDiscount =
        regularPrice != null &&
        discountedPrice != null &&
        regularPrice > 0 &&
        discountedPrice < regularPrice;
    final int? discountPercentage = hasDiscount
        ? (((regularPrice - discountedPrice) / regularPrice) * 100).round()
        : null;
    final int baseDiscount = regularPrice == null
        ? 0
        : (regularPrice * baseDiscountRate / 100).floor();

    String formatRate(double rate) {
      if (rate.isNaN || rate.isInfinite) return '0%';
      return rate % 1 == 0 ? '${rate.toInt()}%' : '${rate.toStringAsFixed(2)}%';
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = bottomInset > 0 ? bottomInset : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title ?? '제품명 없음'),
        actions: [
          if (userId != null)
            IconButton(
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: isInWishlist ? Colors.red : cs.onSurface,
              ),
              onPressed: _toggleWishlist,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
                      tag: 'green-square-product-image-${product.id}',
                      child: resolvedImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: resolvedImageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: cs.surfaceContainerHighest,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                ),
                              ),
                            )
                          : Container(
                              color: cs.surfaceContainerHighest,
                              child: const Icon(
                                Icons.image,
                                size: 64,
                              ),
                            ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                      bottom: bottomPadding,
                      top: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title ?? '제품명 없음',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    if (productWithDetails.seller.username !=
                                            null &&
                                        productWithDetails
                                            .seller
                                            .username!
                                            .isNotEmpty)
                                      TextSpan(
                                        text:
                                            "[${productWithDetails.seller.username ?? 'Unknown Seller'}] ",
                                      ),
                                    TextSpan(
                                      text:
                                          productWithDetails.product.name ?? '',
                                    ),
                                  ],
                                ),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (product.description != null &&
                                  product.description!.isNotEmpty) ...[
                                Text(
                                  product.description!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                formatKRW(regularPrice ?? 0),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (regularPrice != null &&
                                  usableAwardPoints != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Base Discount calculation
                                      Text(
                                        '기본 할인: ${formatKRW(regularPrice.floor())} × ${formatRate(product.baseDiscountRate ?? 0.0)} = ${formatKRW((regularPrice * (product.baseDiscountRate ?? 0.0) / 100).floor())}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      // Selling Price Before Points
                                      Text(
                                        '포인트 적용 전 가격: ${formatKRW(regularPrice.floor())} - ${formatKRW((regularPrice * (product.baseDiscountRate ?? 0.0) / 100).floor())} = ${formatKRW((regularPrice - (regularPrice * (product.baseDiscountRate ?? 0.0) / 100)).floor())}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      // Maximum Discount Rate
                                      Text(
                                        '최대 추가 할인율: ${formatRate(product.platformDiscountRate ?? 0.0)} + ${formatRate(product.vendorDiscountRate ?? 0.0)} = ${formatRate((product.platformDiscountRate ?? 0.0) + (product.vendorDiscountRate ?? 0.0))}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      // Maximum Additional Discount via Points
                                      Text(
                                        '적립금 최대 사용 금액: (${formatKRW((regularPrice - (regularPrice * (product.baseDiscountRate ?? 0.0) / 100)).floor())}) × ${formatRate((product.platformDiscountRate ?? 0.0) + (product.vendorDiscountRate ?? 0.0))} - ${formatKRW((regularPrice * (product.baseDiscountRate ?? 0.0) / 100).floor())} = ${formatKRW(usableAwardPoints)}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      // Final Price
                                      Text(
                                        '최종 결제 금액: ${formatKRW(regularPrice.floor())} - ${formatKRW((regularPrice * (product.baseDiscountRate ?? 0.0) / 100).floor())} - ${formatKRW(usableAwardPoints)} = ${formatKRW(discountedPrice ?? 0)}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (hasDiscount) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '친환경 소비자라면, $discountPercentage%↓',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatKRW(discountedPrice),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: cs.secondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],

                              if (userId != null &&
                                  currentAwardPoints.toInt() > 0) ...[
                                Text(
                                  '보유 마일리지 (c) ${formatKRW((baseDiscount + (usableAwardPoints ?? 0)).toInt())}',

                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              const SizedBox(height: 16),

                              if (isLoadingOptions)
                                const Center(child: CircularProgressIndicator())
                              else if (productColors.isNotEmpty ||
                                  productOptions.isNotEmpty) ...[
                                Text(
                                  '옵션 선택',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (productColors.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Color',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: productColors
                                              .where(
                                                (row) =>
                                                    (row.value ?? '')
                                                        .trim()
                                                        .length ==
                                                    6,
                                              )
                                              .map((row) {
                                                final hex = (row.value ?? '')
                                                    .trim();
                                                final selectedHex =
                                                    (selectedOptionValues['__color__'] ??
                                                            '')
                                                        .trim();
                                                final isSelected =
                                                    selectedHex.toLowerCase() ==
                                                    hex.toLowerCase();
                                                final color = Color(
                                                  int.parse(
                                                    'FF$hex',
                                                    radix: 16,
                                                  ),
                                                );

                                                return Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    customBorder:
                                                        const CircleBorder(),
                                                    onTap: () {
                                                      final bucket = row
                                                          .coloredProductBucket;
                                                      final fileName = row
                                                          .coloredProductFileName;
                                                      final folderPath = row
                                                          .coloredProductFolderPath;

                                                      final nextUrl =
                                                          bucket != null &&
                                                              fileName != null
                                                          ? getImageLink(
                                                              bucket,
                                                              fileName,
                                                              folderPath:
                                                                  folderPath,
                                                            )
                                                          : null;

                                                      setState(() {
                                                        selectedOptionValues['__color__'] =
                                                            hex;
                                                        selectedVariantImageUrl =
                                                            nextUrl;
                                                      });
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
                                                          width: isSelected
                                                              ? 3
                                                              : 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              })
                                              .toList(growable: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ...productOptions.map(
                                  (option) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: option.label,
                                        border: const OutlineInputBorder(),
                                      ),
                                      initialValue:
                                          selectedOptionValues[option.id],
                                      items: option.values
                                          .map(
                                            (
                                              valueRow,
                                            ) => DropdownMenuItem<String>(
                                              value:
                                                  valueRow.value ?? valueRow.id,
                                              child: Text(
                                                valueRow.value ?? valueRow.id,
                                              ),
                                            ),
                                          )
                                          .toList(growable: false),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == null || value.isEmpty) {
                                            selectedOptionValues.remove(
                                              option.id,
                                            );
                                          } else {
                                            selectedOptionValues[option.id] =
                                                value;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ] else
                                const SizedBox.shrink(),

                              const SizedBox(height: 16),

                              // Quantity Selector
                              Text(
                                '수량',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _decreaseQuantity,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text(
                                    '$quantity',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  IconButton(
                                    onPressed: _increaseQuantity,
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Action Buttons
                              ProductActionButtonsBar(
                                key: _actionButtonsKey,
                                isAddingToCart: isAddingToCart,
                                onAddToCart: _addToCart,
                                onPurchase: () async {
                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('로그인이 필요합니다.'),
                                      ),
                                    );
                                    return;
                                  }
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                  final items = await CartService.instance
                                      .fetchCartItems(userId!);
                                  showModalBottomSheet(
                                    context: navigatorKey.currentContext!,
                                    builder: (_) =>
                                        CartBottomSheet(items: items),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            const Tab(text: '제품 설명'),
                            Tab(text: '리뷰 ($reviewCount)'),
                            Tab(text: 'QnA ($qnaCount)'),
                          ],
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: switch (_tabController.index) {
                            0 => ProductDescriptionTab(product: product),
                            1 => ReviewsTab(
                              productId: product.id,
                              averageStars: reviewAverage,
                            ),
                            _ => ProductQnaSection(productId: product.id),
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showStickyActions)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: ProductActionButtonsBar(
                  isAddingToCart: isAddingToCart,
                  onAddToCart: _addToCart,
                  onPurchase: () async {
                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인이 필요합니다.')),
                      );
                      return;
                    }
                    await Future.delayed(const Duration(milliseconds: 100));
                    final items = await CartService.instance.fetchCartItems(
                      userId!,
                    );
                    showModalBottomSheet(
                      context: navigatorKey.currentContext!,
                      builder: (_) => CartBottomSheet(items: items),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
