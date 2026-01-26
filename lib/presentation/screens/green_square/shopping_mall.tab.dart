import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/enums/_enums.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/green_square/product_detail.screen.dart';
import 'package:esg_mobile/presentation/widgets/green_square/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingMallTab extends StatefulWidget {
  const ShoppingMallTab({
    super.key,
    this.onBadgeUpdate,
  });

  final VoidCallback? onBadgeUpdate;

  @override
  State<ShoppingMallTab> createState() => _ShoppingMallTabState();
}

class _ShoppingMallTabState extends State<ShoppingMallTab>
    with TickerProviderStateMixin {
  double awardPoints = 0.0;
  final TextEditingController _searchController = TextEditingController();
  String selectedCategoryId = 'All';
  List<ProductCategoryRow> categories = [];
  List<ProductWithOtherDetails> products = [];
  bool isLoading = true;
  String? userId;
  int cartItemCount = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _createOrUpdateTabController();
    _loadData();
  }

  void _createOrUpdateTabController() {
    final desiredLength = categories.length + 1;

    if (desiredLength <= 0) {
      _tabController?.removeListener(_handleTabChange);
      _tabController?.dispose();
      _tabController = null;
      return;
    }

    if (_tabController != null && _tabController!.length == desiredLength) {
      _syncSelectedTab();
      return;
    }

    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();

    final controller = TabController(length: desiredLength, vsync: this);
    controller.addListener(_handleTabChange);
    _tabController = controller;
    _syncSelectedTab();
  }

  void _syncSelectedTab() {
    final controller = _tabController;
    if (controller == null) {
      return;
    }

    var targetIndex = 0;
    if (selectedCategoryId != 'All') {
      final matchIndex = categories.indexWhere(
        (category) => category.id == selectedCategoryId,
      );
      if (matchIndex != -1) {
        targetIndex = matchIndex + 1;
      } else {
        selectedCategoryId = 'All';
      }
    }

    if (targetIndex >= controller.length) {
      targetIndex = 0;
      selectedCategoryId = 'All';
    }

    if (controller.index != targetIndex) {
      controller.index = targetIndex;
    }
  }

  void _handleTabChange() {
    if (!mounted || _tabController == null || _tabController!.indexIsChanging) {
      return;
    }

    final index = _tabController!.index;
    final newCategoryId = index == 0 ? 'All' : categories[index - 1].id;

    if (newCategoryId == selectedCategoryId) {
      return;
    }

    setState(() => selectedCategoryId = newCategoryId);
    _loadProducts();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final pointsRow = await Supabase.instance.client
            .from('award_points')
            .select('points')
            .eq('"user"', userId!)
            .maybeSingle();
        awardPoints = (pointsRow?['points'] as num?)?.toDouble() ?? 0.0;
        _loadCartCount();
      }

      final fetchedCategories = await ProductService.instance.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        final categoryStillExists =
            selectedCategoryId == 'All' ||
            categories.any((category) => category.id == selectedCategoryId);
        if (!categoryStillExists) {
          selectedCategoryId = 'All';
        }
        _createOrUpdateTabController();
      });

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
      vendor: VendorAdminType.retailer,
    );
    if (mounted) {
      setState(() => products = fetchedProducts);
    }
  }

  Future<void> _toggleWishlist(
    ProductWithOtherDetails productWithDetails,
    bool isInWishlist,
  ) async {
    if (userId == null) {
      // Handle not logged in - maybe show login prompt
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

      // Update the local state
      setState(() {
        final index = products.indexWhere(
          (p) => p.product.id == productWithDetails.product.id,
        );
        if (index != -1) {
          products[index] = ProductWithOtherDetails(
            product: productWithDetails.product,
            seller: productWithDetails.seller,
            categoryName: productWithDetails.categoryName,
            images: productWithDetails.images,
            isInWishlist: !productWithDetails.isInWishlist,
          );
        }
      });
      widget.onBadgeUpdate?.call();
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      if (!mounted) return;
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
          _loadProducts();
          _loadCartCount();
          widget.onBadgeUpdate?.call();
        });
  }

  Future<void> _loadCartCount() async {
    if (userId == null) {
      return;
    }
    final items = await CartService.instance.fetchCartItems(userId!);
    if (mounted) {
      setState(() => cartItemCount = items.length);
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final mileageText = awardPoints == awardPoints.roundToDouble()
        ? NumberFormat.decimalPattern().format(awardPoints.toInt())
        : NumberFormat('#,##0.0').format(awardPoints);

    return SingleChildScrollView(
      // padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      padding: EdgeInsets.zero,
      primary: false,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Award Points Display
          Center(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              constraints: BoxConstraints(
                maxWidth: 800,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.network(
                    getImageLink(
                      bucket.asset,
                      asset.cMilage,
                      folderPath: assetFolderPath[asset.cMilage],
                    ),
                    width: 20,
                    height: 20,
                    semanticsLabel: '마일리지',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mileageText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '(현재 보유 마일리지)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Center(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              constraints: BoxConstraints(
                maxWidth: 800,
              ),
              child: TextField(
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
            ),
          ),
          const SizedBox(height: 16),

          // Category Tabs
          if (_tabController != null &&
              _tabController!.length == categories.length + 1)
            Center(
              child: Container(
                height: 30,
                constraints: BoxConstraints(
                  maxWidth: 800,
                ),
                child: TabBar(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: cs.secondary,
                  indicatorWeight: 3,
                  labelColor: cs.onSurface,
                  unselectedLabelColor: cs.outline,
                  labelPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: theme.textTheme.bodySmall,
                  tabs: [
                    const Tab(text: '전체'),
                    ...categories.map((category) => Tab(text: category.name)),
                  ],
                ),
              ),
            ),

          // Products Grid
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (products.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('상품이 없습니다.'),
              ),
            )
          else
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    if (constraints.maxWidth >= 1200) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth >= 700) {
                      crossAxisCount = 3;
                    }
                    return MasonryGridView.count(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final productWithDetails = products[index];
                        return ProductCard(
                          productWithDetails: productWithDetails,
                          onWishlistToggle: (isInWishlist) =>
                              _toggleWishlist(productWithDetails, isInWishlist),
                          onTap: () =>
                              _navigateToProductDetail(productWithDetails),
                        );
                      },
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
