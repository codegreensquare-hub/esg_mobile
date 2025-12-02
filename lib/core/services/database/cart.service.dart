import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:esg_mobile/data/entities/cart_item_with_product.dart';
import 'package:esg_mobile/data/entities/product_option_definition.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class CartService {
  CartService._();

  static final CartService instance = CartService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CartItemWithProduct>> fetchCartItems(String userId) async {
    try {
      final response = await _client
          .from(CartItemTable().tableName)
          .select(
            '*, product:product(*), cart_item_option(*)',
          )
          .eq(CartItemRow.customerField, userId)
          .order(CartItemRow.createdAtField, ascending: false);

      return response.whereType<Map<String, dynamic>>().map((data) {
        final productData = data['product'] as Map<String, dynamic>?;
        if (productData == null) {
          throw Exception('Missing product information in cart response');
        }
        final optionsData = data['cart_item_option'] as List<dynamic>? ?? [];
        return CartItemWithProduct(
          cartItem: CartItemRow.fromJson(data),
          product: ProductRow.fromJson(productData),
          options: optionsData
              .whereType<Map<String, dynamic>>()
              .map(CartItemOptionRow.fromJson)
              .toList(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
      return [];
    }
  }

  Future<CartItemRow?> addItem({
    required String userId,
    required String productCode,
    required double quantity,
    Map<String, String> selectedOptions = const {},
  }) async {
    try {
      final inserted = await _client
          .from(CartItemTable().tableName)
          .insert({
            CartItemRow.customerField: userId,
            CartItemRow.productField: productCode,
            CartItemRow.quantityField: quantity,
          })
          .select()
          .single();

      final cartItem = CartItemRow.fromJson(inserted);

      if (selectedOptions.isNotEmpty) {
        final payload = selectedOptions.entries
            .map(
              (entry) => {
                CartItemOptionRow.cartItemField: cartItem.id,
                CartItemOptionRow.optionField: entry.key,
                CartItemOptionRow.valueField: entry.value,
              },
            )
            .toList();

        await _client.from(CartItemOptionTable().tableName).insert(payload);
      }

      return cartItem;
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
      return null;
    }
  }

  Future<bool> updateQuantity({
    required String cartItemId,
    required double quantity,
  }) async {
    try {
      await _client
          .from(CartItemTable().tableName)
          .update({CartItemRow.quantityField: quantity})
          .eq(CartItemRow.idField, cartItemId);
      return true;
    } catch (e) {
      debugPrint('Error updating cart quantity: $e');
      return false;
    }
  }

  Future<bool> removeItem(String cartItemId) async {
    try {
      await _client
          .from(CartItemTable().tableName)
          .delete()
          .eq(CartItemRow.idField, cartItemId);
      return true;
    } catch (e) {
      debugPrint('Error removing cart item: $e');
      return false;
    }
  }

  Future<List<ProductOptionDefinition>> fetchProductOptions(
    String productId,
  ) async {
    try {
      final response = await _client
          .from(ProductOptionParameterTable().tableName)
          .select('*')
          .eq(ProductOptionParameterRow.productField, productId);

      final parameterRows = response
          .whereType<Map<String, dynamic>>()
          .map(ProductOptionParameterRow.fromJson)
          .toList();

      if (parameterRows.isEmpty) {
        return [];
      }

      final optionParameterIds = parameterRows
          .map((row) => row.optionParameter)
          .whereType<String>()
          .toList();

      final valuesByParameter = <String, List<ProductOptionValueRow>>{};
      if (optionParameterIds.isNotEmpty) {
        final valuesResponse = await _client
            .from(ProductOptionValueTable().tableName)
            .select('*')
            .filter(
              ProductOptionValueRow.optionParameterField,
              'in',
              '(${optionParameterIds.map((id) => '"$id"').join(',')})',
            );

        for (final data in valuesResponse.whereType<Map<String, dynamic>>()) {
          final row = ProductOptionValueRow.fromJson(data);
          final key = row.optionParameter;
          if (key == null) {
            continue;
          }
          valuesByParameter.putIfAbsent(key, () => []).add(row);
        }
      }

      return parameterRows
          .map((row) {
            final parameterId = row.optionParameter ?? row.id;
            final values =
                valuesByParameter[row.optionParameter] ??
                valuesByParameter[row.id] ??
                <ProductOptionValueRow>[];

            return ProductOptionDefinition(
              id: parameterId,
              label: row.optionParameter ?? '옵션',
              parameterRowId: row.id,
              values: values,
            );
          })
          .where((definition) => definition.values.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error fetching product options: $e');
      return [];
    }
  }
}
