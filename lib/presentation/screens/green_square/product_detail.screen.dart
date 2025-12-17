import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_option_definition.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/enums/product_sale_status.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productWithDetails,
  });

  final ProductWithOtherDetails productWithDetails;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductWithOtherDetails productWithDetails;
  bool isInWishlist = false;
  String? userId;
  int quantity = 1;
  bool isAddingToCart = false;
  bool isLoadingOptions = true;
  List<ProductOptionDefinition> productOptions = [];
  final Map<String, String> selectedOptionValues = {};

  @override
  void initState() {
    super.initState();
    productWithDetails = widget.productWithDetails;
    userId = Supabase.instance.client.auth.currentUser?.id;
    isInWishlist = productWithDetails.isInWishlist;
    _loadProductOptions();
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
    if (!mounted) {
      return;
    }
    setState(() {
      productOptions = options;
      isLoadingOptions = false;
    });
  }

  void _increaseQuantity() {
    final stockLimit = productWithDetails.product.stockQuantity.toInt();
    setState(() {
      quantity = (quantity + 1).clamp(1, stockLimit).toInt();
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

    if (hasMissingOption) {
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
      };

      final result = await CartService.instance.addItem(
        userId: userId!,
        productCode: productWithDetails.product.id,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title ?? product.code),
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
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Code
                  Text(
                    product.title ?? product.code,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category
                  if (productWithDetails.categoryName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        productWithDetails.categoryName!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Price
                  Text(
                    formatKRW(product.regularPrice ?? 0),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.regularPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatKRW(product.regularPrice!),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Description
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    Text(
                      '상품 설명',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stock Information
                  Row(
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '재고: ${product.stockQuantity.toInt()}개',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sale Status
                  Row(
                    children: [
                      Icon(
                        product.saleStatus == ProductSaleStatus.on_sale
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 20,
                        color: product.saleStatus == ProductSaleStatus.on_sale
                            ? Colors.green
                            : cs.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.saleStatus == ProductSaleStatus.on_sale
                            ? '판매 중'
                            : '판매 중지',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: product.saleStatus == ProductSaleStatus.on_sale
                              ? Colors.green
                              : cs.error,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

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

                  const SizedBox(height: 24),

                  if (isLoadingOptions)
                    const Center(child: CircularProgressIndicator())
                  else if (productOptions.isNotEmpty) ...[
                    Text(
                      '옵션 선택',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                              .toList(),
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

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              isAddingToCart ||
                                  product.saleStatus !=
                                      ProductSaleStatus.on_sale
                              ? null
                              : _addToCart,
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement purchase functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('구매 기능은 곧 추가됩니다.')),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('구매하기'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
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
