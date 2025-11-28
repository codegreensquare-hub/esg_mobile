import 'package:flutter/foundation.dart';

import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  static final ProductService instance = ProductService._();
  ProductService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ProductWithOtherDetails>> fetchProducts({
    String? categoryId,
    String? searchQuery,
  }) async {
    try {
      var query = _client
          .from(ProductTable().tableName)
          .select('*, product_category(name), product_image(*)')
          .eq(ProductRow.saleStatusField, 'on_sale');

      if (categoryId != null && categoryId != 'All') {
        query = query.eq(ProductRow.categoryField, categoryId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike(ProductRow.codeField, '%$searchQuery%');
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((data) {
        final product = ProductRow.fromJson(data);
        final categoryData = data['product_category'] as Map<String, dynamic>?;
        final categoryName = categoryData?['name'] as String?;
        final imagesData = data['product_image'] as List<dynamic>? ?? [];
        final images = imagesData
            .map((img) => ProductImageRow.fromJson(img as Map<String, dynamic>))
            .toList();

        return ProductWithOtherDetails(
          product: product,
          categoryName: categoryName,
          images: images,
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

  Future<int> getUserAwardPoints(String userId) async {
    try {
      // For now, return static value. In future, fetch from user profile or award_points table
      return 5000;
    } catch (e) {
      debugPrint('Error fetching award points: $e');
      return 0;
    }
  }
}
