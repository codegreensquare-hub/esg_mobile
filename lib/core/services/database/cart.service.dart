import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:esg_mobile/data/entities/cart_item_with_product.dart';
import 'package:esg_mobile/data/entities/product_option_definition.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class CartService {
  CartService._();

  static final CartService instance = CartService._();

  final SupabaseClient _client = Supabase.instance.client;

  String _optionsSignature(Map<String, String> selectedOptions) {
    final normalized =
        selectedOptions.entries
            .where((e) => e.key.isNotEmpty && e.value.isNotEmpty)
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
            .map((o) => '${o.option}=${o.value}')
            .toList(growable: false)
          ..sort();
    return normalized.join('|');
  }

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
      final requestedSignature = _optionsSignature(selectedOptions);

      final existingResponse = await _client
          .from(CartItemTable().tableName)
          .select('*, cart_item_option(*)')
          .eq(CartItemRow.customerField, userId)
          .eq(CartItemRow.productField, productCode);

      final existingItems = existingResponse
          .whereType<Map<String, dynamic>>()
          .map((row) {
            final item = CartItemRow.fromJson(row);
            final optionsData = row['cart_item_option'] as List<dynamic>? ?? [];
            final options = optionsData
                .whereType<Map<String, dynamic>>()
                .map(CartItemOptionRow.fromJson)
                .toList(growable: false);
            return (item: item, signature: _cartItemOptionsSignature(options));
          })
          .toList(growable: false);

      final matching = existingItems.where(
        (e) => e.signature == requestedSignature,
      );
      final existingMatch = matching.isEmpty ? null : matching.first.item;

      if (existingMatch != null) {
        final updated = await _client
            .from(CartItemTable().tableName)
            .update({
              CartItemRow.quantityField: existingMatch.quantity + quantity,
            })
            .eq(CartItemRow.idField, existingMatch.id)
            .select()
            .single();

        return CartItemRow.fromJson(updated);
      }

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
            .where((entry) => entry.key.isNotEmpty && entry.value.isNotEmpty)
            .map(
              (entry) => {
                CartItemOptionRow.cartItemField: cartItem.id,
                CartItemOptionRow.optionField: entry.key,
                CartItemOptionRow.valueField: entry.value,
              },
            )
            .toList();

        if (payload.isNotEmpty) {
          await _client.from(CartItemOptionTable().tableName).insert(payload);
        }
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

  Future<bool> removeItem({
    required String cartItemId,
  }) async {
    try {
      await _client
          .from(CartItemOptionTable().tableName)
          .delete()
          .eq(CartItemOptionRow.cartItemField, cartItemId);

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

  Future<String?> checkoutCart({
    required String shippingAddressId,
  }) async {
    final normalized = shippingAddressId.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('shippingAddressId is required');
    }

    // Defensive cleanup: older buggy clients could have inserted cart items with
    // an empty product id, which will crash checkout when the DB expects UUIDs.
    final userId = _client.auth.currentUser?.id;
    if (userId != null && userId.trim().isNotEmpty) {
      final rows = await _client
          .from(CartItemTable().tableName)
          .select('id, product')
          .eq(CartItemRow.customerField, userId);

      final invalidIds = rows
          .whereType<Map<String, dynamic>>()
          .map(
            (r) => (
              id: (r[CartItemRow.idField] as String?)?.trim(),
              product: (r[CartItemRow.productField] as String?)?.trim(),
            ),
          )
          .where((e) => (e.id ?? '').isNotEmpty && (e.product ?? '').isEmpty)
          .map((e) => e.id!)
          .toList(growable: false);

      if (invalidIds.isNotEmpty) {
        final inFilter = '(${invalidIds.map((id) => '"$id"').join(',')})';
        await _client
            .from(CartItemOptionTable().tableName)
            .delete()
            .filter(CartItemOptionRow.cartItemField, 'in', inFilter);
        await _client
            .from(CartItemTable().tableName)
            .delete()
            .filter(CartItemRow.idField, 'in', inFilter);

        throw StateError(
          '장바구니에 잘못된 상품이 있어 정리했습니다. 다시 결제를 시도해주세요.',
        );
      }
    }

    debugPrint('Checking out cart with shippingAddressId: "$normalized"');
    final response = await _client.rpc(
      'checkout_cart',
      params: {
        'p_shipping_address': normalized,
      },
    );
    debugPrint('Checkout response: $response');
    return response as String?;
  }
}
