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
        query = query.ilike(ProductRow.codeField, '%$searchQuery%');
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

  Future<int> getUserAwardPoints(String userId) async {
    try {
      // Assuming there's a user_award_points table or similar
      // For now, return a default value or implement based on your schema
      // You may need to adjust this based on your actual database structure
      final response = await _client
          .from('user_award_points') // Replace with actual table name
          .select('points')
          .eq('user_id', userId)
          .maybeSingle();

      return response?['points'] as int? ?? 0;
    } catch (e) {
      debugPrint('Error fetching user award points: $e');
      return 0;
    }
  }
}
