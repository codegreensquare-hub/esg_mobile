import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_option_definition.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:esg_mobile/presentation/widgets/green_square/product_description_tab.dart';
import 'package:esg_mobile/presentation/widgets/green_square/reviews_tab.dart';

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
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    productWithDetails = widget.productWithDetails;
    userId = Supabase.instance.client.auth.currentUser?.id;
    isInWishlist = productWithDetails.isInWishlist;
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);
    _loadProductOptions();
    _loadAwardPoints();
  }

  void _handleTabChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleWishlist() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      await ProductService.instance.toggleWishlist(
        productWithDetails.product.id,
        userId!,
      );

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
    final double? discountedPrice = product.minimumPriceMinusAwardPoints;
    final hasDiscount =
        regularPrice != null &&
        discountedPrice != null &&
        regularPrice > 0 &&
        discountedPrice < regularPrice;
    final int? discountPercentage = hasDiscount
        ? (((regularPrice - discountedPrice) / regularPrice) * 100).round()
        : null;

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            AspectRatio(
              aspectRatio: 1,
              child: Hero(
                tag: 'green-square-product-image-${product.id}',
                child: resolvedImageUrl != null
                    ? Image.network(
                        resolvedImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
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
                left: 16,
                right: 16,
                bottom: bottomPadding,
                top: 16,
              ),
              child: Column(
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
                        if (productWithDetails.seller.username != null &&
                            productWithDetails.seller.username!.isNotEmpty)
                          TextSpan(
                            text:
                                "[${productWithDetails.seller.username ?? 'Unknown Seller'}] ",
                          ),
                        TextSpan(
                          text: productWithDetails.product.name ?? '',
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

                  if (userId != null) ...[
                    Text(
                      '보유 마일리지 (c) ${formatKRW(currentAwardPoints.toInt())}',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              children: productColors
                                  .where(
                                    (row) =>
                                        (row.value ?? '').trim().length == 6,
                                  )
                                  .map((row) {
                                    final hex = (row.value ?? '').trim();
                                    final selectedHex =
                                        (selectedOptionValues['__color__'] ??
                                                '')
                                            .trim();
                                    final isSelected =
                                        selectedHex.toLowerCase() ==
                                        hex.toLowerCase();
                                    final color = Color(
                                      int.parse('FF$hex', radix: 16),
                                    );

                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () {
                                          final bucket =
                                              row.coloredProductBucket;
                                          final fileName =
                                              row.coloredProductFileName;
                                          final folderPath =
                                              row.coloredProductFolderPath;

                                          final nextUrl =
                                              bucket != null && fileName != null
                                              ? getImageLink(
                                                  bucket,
                                                  fileName,
                                                  folderPath: folderPath,
                                                )
                                              : null;

                                          setState(() {
                                            selectedOptionValues['__color__'] =
                                                hex;
                                            selectedVariantImageUrl = nextUrl;
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
                          initialValue: selectedOptionValues[option.id],
                          items: option.values
                              .map(
                                (valueRow) => DropdownMenuItem<String>(
                                  value: valueRow.value ?? valueRow.id,
                                  child: Text(valueRow.value ?? valueRow.id),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              if (value == null || value.isEmpty) {
                                selectedOptionValues.remove(option.id);
                              } else {
                                selectedOptionValues[option.id] = value;
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
                        icon: const Icon(Icons.remove_circle_outline),
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
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isAddingToCart ? null : _addToCart,
                          icon: isAddingToCart
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_shopping_cart),
                          label: Text(
                            isAddingToCart ? '담는 중...' : '장바구니 담기',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement purchase functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('구매 기능은 곧 추가됩니다.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('구매하기'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: '제품 설명'),
                      Tab(text: '리뷰 (0)'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _tabController.index == 0
                        ? ProductDescriptionTab(product: product)
                        : ReviewsTab(product: product),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
