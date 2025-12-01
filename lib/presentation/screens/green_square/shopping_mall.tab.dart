import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/widgets/green_square/product_card.dart';
import 'package:esg_mobile/presentation/screens/green_square/product_detail.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingMallTab extends StatefulWidget {
  const ShoppingMallTab({super.key});

  @override
  State<ShoppingMallTab> createState() => _ShoppingMallTabState();
}

class _ShoppingMallTabState extends State<ShoppingMallTab> {
  int awardPoints = 0;
  final TextEditingController _searchController = TextEditingController();
  String selectedCategoryId = 'All';
  List<ProductCategoryRow> categories = [];
  List<ProductWithOtherDetails> products = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        awardPoints = await ProductService.instance.getUserAwardPoints(userId!);
      }

      categories = await ProductService.instance.fetchCategories();

      await _loadProducts();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loadProducts() async {
    final fetchedProducts = await ProductService.instance.fetchProducts(
      categoryId: selectedCategoryId == 'All' ? null : selectedCategoryId,
      searchQuery: _searchController.text.isEmpty
          ? null
          : _searchController.text,
      userId: userId,
    );
    if (mounted) {
      setState(() => products = fetchedProducts);
    }
  }

  Future<void> _toggleWishlist(
    ProductWithOtherDetails productWithDetails,
  ) async {
    if (userId == null) {
      // Handle not logged in - maybe show login prompt
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      await ProductService.instance.toggleWishlist(
        productWithDetails.product.code,
        userId!,
      );

      // Update the local state
      setState(() {
        final index = products.indexWhere(
          (p) => p.product.code == productWithDetails.product.code,
        );
        if (index != -1) {
          products[index] = ProductWithOtherDetails(
            product: productWithDetails.product,
            categoryName: productWithDetails.categoryName,
            images: productWithDetails.images,
            isInWishlist: !productWithDetails.isInWishlist,
          );
        }
      });
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('찜하기 처리 중 오류가 발생했습니다.')),
      );
    }
  }

  void _navigateToProductDetail(ProductWithOtherDetails productWithDetails) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productWithDetails: productWithDetails,
            ),
          ),
        )
        .then((_) {
          // Refresh products when returning from detail screen
          // to update wishlist status if it was changed
          _loadProducts();
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Award Points Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '사용 가능 포인트',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '$awardPoints P',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '상품 검색',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
            onChanged: (value) => _loadProducts(),
          ),
          const SizedBox(height: 16),

          // Category Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1, // +1 for 'All'
              itemBuilder: (context, index) {
                if (index == 0) {
                  // 'All' category
                  final category = 'All';
                  final isSelected = selectedCategoryId == category;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategoryId = selected ? category : 'All';
                        });
                        _loadProducts();
                      },
                      backgroundColor: cs.surfaceContainer,
                      selectedColor: cs.primaryContainer,
                      checkmarkColor: cs.onPrimaryContainer,
                    ),
                  );
                } else {
                  final category = categories[index - 1];
                  final isSelected = selectedCategoryId == category.id;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategoryId = selected ? category.id : 'All';
                        });
                        _loadProducts();
                      },
                      backgroundColor: cs.surfaceContainer,
                      selectedColor: cs.primaryContainer,
                      checkmarkColor: cs.onPrimaryContainer,
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // Products Grid
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (products.isEmpty)
            const Center(child: Text('상품이 없습니다.'))
          else
            MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final productWithDetails = products[index];
                return ProductCard(
                  productWithDetails: productWithDetails,
                  onWishlistToggle: userId != null
                      ? () => _toggleWishlist(productWithDetails)
                      : null,
                  onTap: () => _navigateToProductDetail(productWithDetails),
                );
              },
            ),
        ],
      ),
    );
  }
}
