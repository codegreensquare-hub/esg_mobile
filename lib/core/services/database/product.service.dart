import 'package:flutter/foundation.dart';

import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/entities/wishlisted_product.dart';
import 'package:esg_mobile/data/models/supabase/enums/_enums.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  static final ProductService instance = ProductService._();
  ProductService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ProductWithOtherDetails>> fetchProducts({
    String? categoryId,
    String? searchQuery,
    String? userId,
    VendorAdminType? vendor,
    ProductStyle? style,
    ProductMaterial? material,
    bool? isCuration,
    String? company,
    String orderByField = ProductRow.createdAtField,
    bool orderAscending = false,
    int? limit,
  }) async {
    try {
      var query = _client
          .from(ProductTable().tableName)
          .select(
            '*, product_category(name), product_image(*), user:product_by(*)',
          );

      if (categoryId != null && categoryId != 'All') {
        query = query.eq(ProductRow.categoryField, categoryId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Products no longer have a separate "code" field; search by title.
        query = query.ilike(ProductRow.titleField, '%$searchQuery%');
      }

      if (vendor != null) {
        query = query.eq(ProductRow.vendorField, vendor.name);
      }

      if (style != null) {
        query = query.eq(ProductRow.styleField, style.name);
      }

      if (material != null) {
        query = query.eq(ProductRow.typeField, material.name);
      }

      if (isCuration != null) {
        query = query.eq(ProductRow.isCurationField, isCuration);
      }

      if (company != null) {
        query = query.eq(ProductRow.companyField, company);
      }

      var finalQuery = query.order(orderByField, ascending: orderAscending);

      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;

      // Get wishlist status for each product if user is logged in
      final wishlistStatuses = <String, bool>{};
      if (userId != null) {
        final wishlistResponse = await _client
            .from(ProductWishlistTable().tableName)
            .select(ProductWishlistRow.productField)
            .eq(ProductWishlistRow.wishlistByField, userId);

        for (final item in wishlistResponse) {
          wishlistStatuses[item[ProductWishlistRow.productField] as String] =
              true;
        }
      }

      return response.map((data) {
        final product = ProductRow.fromJson(data);
        final categoryData = data['product_category'] as Map<String, dynamic>?;
        final categoryName = categoryData?['name'] as String?;
        final imagesData = data['product_image'] as List<dynamic>? ?? [];
        final images = imagesData
            .map((img) => ProductImageRow.fromJson(img as Map<String, dynamic>))
            .toList();
        final isInWishlist = wishlistStatuses[product.id] ?? false;
        final sellerData = data['user'] as Map<String, dynamic>?;
        if (sellerData == null) {
          throw Exception('Seller data missing for product ${product.id}');
        }
        final seller = UserRow.fromJson(sellerData);

        return ProductWithOtherDetails(
          product: product,
          seller: seller,
          categoryName: categoryName,
          images: images,
          isInWishlist: isInWishlist,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  Future<List<ProductWithOtherDetails>> fetchProductsByIds({
    required List<String> productIds,
    String? userId,
    int? limit,
  }) async {
    if (productIds.isEmpty) {
      return [];
    }

    try {
      final uniqueIds = productIds.toSet().toList();
      final response = await _client
          .from(ProductTable().tableName)
          .select(
            '*, product_category(name), product_image(*), user:product_by(*)',
          )
          .inFilter(ProductRow.idField, uniqueIds);

      final wishlistProductIds = <String>{};
      if (userId != null) {
        final wishlistResponse = await _client
            .from(ProductWishlistTable().tableName)
            .select(ProductWishlistRow.productField)
            .eq(ProductWishlistRow.wishlistByField, userId)
            .inFilter(ProductWishlistRow.productField, uniqueIds);

        wishlistProductIds.addAll(
          (wishlistResponse as List).map(
            (row) => row[ProductWishlistRow.productField] as String,
          ),
        );
      }

      final products = (response as List).map((data) {
        final product = ProductRow.fromJson(data);
        final categoryData = data['product_category'] as Map<String, dynamic>?;
        final categoryName = categoryData?['name'] as String?;
        final imagesData = data['product_image'] as List<dynamic>? ?? [];
        final images = imagesData
            .whereType<Map<String, dynamic>>()
            .map(ProductImageRow.fromJson)
            .toList();
        final sellerData = data['user'] as Map<String, dynamic>?;
        if (sellerData == null) {
          throw Exception('Seller data missing for product ${product.id}');
        }
        final seller = UserRow.fromJson(sellerData);

        return ProductWithOtherDetails(
          product: product,
          seller: seller,
          categoryName: categoryName,
          images: images,
          isInWishlist: wishlistProductIds.contains(product.id),
        );
      }).toList();

      final indexById = productIds.asMap().map(
        (index, id) => MapEntry(id, index),
      );

      products.sort(
        (a, b) => (indexById[a.product.id] ?? 1 << 30).compareTo(
          indexById[b.product.id] ?? 1 << 30,
        ),
      );

      return limit == null ? products : products.take(limit).toList();
    } catch (e) {
      debugPrint('Error fetching products by ids: $e');
      return [];
    }
  }

  Future<List<ProductCategoryRow>> fetchCategories() async {
    try {
      final response = await _client
          .from(ProductCategoryTable().tableName)
          .select('*')
          .order('name');

      return response.map((data) => ProductCategoryRow.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<bool> isProductInWishlist(String productId, String userId) async {
    try {
      final response = await _client
          .from(ProductWishlistTable().tableName)
          .select()
          .eq(ProductWishlistRow.productField, productId)
          .eq(ProductWishlistRow.wishlistByField, userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking wishlist status: $e');
      return false;
    }
  }

  Future<void> toggleWishlist(String productId, String userId) async {
    try {
      final isInWishlist = await isProductInWishlist(productId, userId);

      if (isInWishlist) {
        // Remove from wishlist
        await _client
            .from(ProductWishlistTable().tableName)
            .delete()
            .eq(ProductWishlistRow.productField, productId)
            .eq(ProductWishlistRow.wishlistByField, userId);
      } else {
        // Add to wishlist
        await _client.from(ProductWishlistTable().tableName).insert({
          ProductWishlistRow.productField: productId,
          ProductWishlistRow.wishlistByField: userId,
          ProductWishlistRow.createdAtField: DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      rethrow;
    }
  }

  Future<List<WishlistedProduct>> fetchWishlistedProducts(String userId) async {
    try {
      final response = await _client
          .from(ProductWishlistTable().tableName)
          .select(
            'created_at, product:product(*, product_category(name), product_image(*), user:product_by(*))',
          )
          .eq(ProductWishlistRow.wishlistByField, userId)
          .order(ProductWishlistRow.createdAtField, ascending: false);

      return response.map((data) {
        final productData = data['product'] as Map<String, dynamic>?;
        if (productData == null) {
          throw Exception('Wishlist entry missing product data');
        }

        final product = ProductRow.fromJson(productData);
        final categoryData =
            productData['product_category'] as Map<String, dynamic>?;
        final categoryName = categoryData?['name'] as String?;
        final imagesData =
            productData['product_image'] as List<dynamic>? ?? <dynamic>[];
        final images = imagesData
            .map((img) => ProductImageRow.fromJson(img as Map<String, dynamic>))
            .toList();
        final sellerData = productData['user'] as Map<String, dynamic>?;
        if (sellerData == null) {
          throw Exception(
            'Seller data missing for wishlisted product ${product.id}',
          );
        }
        final seller = UserRow.fromJson(sellerData);

        return WishlistedProduct(
          product: ProductWithOtherDetails(
            product: product,
            seller: seller,
            categoryName: categoryName,
            images: images,
            isInWishlist: true,
          ),
          createdAt: DateTime.parse(data['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching wishlisted products: $e');
      return [];
    }
  }

  Future<double> getUserAwardPoints(String userId) async {
    try {
      final response = await _client
          .from('award_points')
          .select('points')
          .eq('user', userId)
          .maybeSingle();

      return response?['points'] as double? ?? 0.0;
    } catch (e) {
      debugPrint('Error fetching user award points: $e');
      return 0.0;
    }
  }

  Future<List<ProductReviewRow>> fetchProductReviews(
    String productId, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client
          .from(ProductReviewTable().tableName)
          .select()
          .eq(ProductReviewRow.productField, productId)
          .order(ProductReviewRow.createdAtField, ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return response.map(ProductReviewRow.fromJson).toList();
    } catch (e) {
      debugPrint('Error fetching product reviews: $e');
      return [];
    }
  }

  Future<double> getProductAverageStars(String productId) async {
    try {
      final response = await _client
          .from(ProductReviewTable().tableName)
          .select('stars')
          .eq(ProductReviewRow.productField, productId);

      if (response.isEmpty) return 0.0;

      final total = response.fold<double>(
        0.0,
        (sum, item) => sum + (item['stars'] as num),
      );
      return total / response.length;
    } catch (e) {
      debugPrint('Error fetching product average stars: $e');
      return 0.0;
    }
  }

  Future<int> getProductReviewCount(String productId) async {
    try {
      final response = await _client
          .from(ProductReviewTable().tableName)
          .select('*')
          .eq(ProductReviewRow.productField, productId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      debugPrint('Error fetching product review count: $e');
      return 0;
    }
  }
}
