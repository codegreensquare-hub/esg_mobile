import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:esg_mobile/data/entities/cart_item_with_product.dart';
import 'package:esg_mobile/data/entities/product_option_definition.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class CartService {
  CartService._();

  static final CartService instance = CartService._();

  final SupabaseClient _client = Supabase.instance.client;

  final Map<String, Future<List<ProductOptionDefinition>>> _optionsMemo = {};

  final Map<String, Future<List<ProductOptionColorRow>>> _colorOptionsMemo = {};

  Future<Map<String, String>> fetchColorHexByIds(
    Iterable<String> colorIds,
  ) async {
    final ids = colorIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return const {};

    try {
      final response = await _client
          .from(ProductOptionColorTable().tableName)
          .select(
            '${ProductOptionColorRow.idField}, ${ProductOptionColorRow.valueField}',
          )
          .inFilter(ProductOptionColorRow.idField, ids);

      final rows = response
          .whereType<Map<String, dynamic>>()
          .map(ProductOptionColorRow.fromJson)
          .toList(growable: false);

      return {
        for (final row in rows)
          if ((row.value ?? '').trim().isNotEmpty)
            row.id: (row.value ?? '').trim(),
      };
    } catch (e) {
      debugPrint('Error fetching color hex by ids: $e');
      return const {};
    }
  }

  Future<List<ProductOptionColorRow>> fetchColorOptionValues({
    required String productId,
  }) {
    final pid = productId.trim();
    if (pid.isEmpty) {
      return Future.value(const []);
    }

    final cached = _colorOptionsMemo[pid];
    if (cached != null) {
      return cached;
    }

    final future = _client
        .from(ProductOptionColorTable().tableName)
        .select('*')
        .eq(ProductOptionColorRow.productField, pid)
        .then(
          (rows) => rows
              .whereType<Map<String, dynamic>>()
              .map(ProductOptionColorRow.fromJson)
              .where((row) => (row.value ?? '').trim().length == 6)
              .toList(growable: false),
        )
        .catchError((_) => <ProductOptionColorRow>[]);

    _colorOptionsMemo[pid] = future;
    return future;
  }

  String _optionsSignature(Map<String, String> selectedOptions) {
    final normalized =
        selectedOptions.entries
            .where(
              (e) =>
                  e.key.isNotEmpty &&
                  e.value.isNotEmpty &&
                  e.key.toLowerCase() != 'color',
            )
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
            .where((o) => (o.option ?? '').toLowerCase() != 'color')
            .map((o) => '${o.option}=${o.value}')
            .toList(growable: false)
          ..sort();
    return normalized.join('|');
  }

  String _extractRequestedColor(Map<String, String> selectedOptions) {
    final entry = selectedOptions.entries
        .where((e) => e.key.toLowerCase() == 'color')
        .map((e) => e.value)
        .where((v) => v.trim().isNotEmpty)
        .map((v) => v.trim())
        .toList(growable: false);
    return entry.isEmpty ? '' : entry.first;
  }

  String _extractExistingColor(
    CartItemRow item,
    List<CartItemOptionRow> options,
  ) {
    final fromField = (item.optionColor ?? '').trim();
    if (fromField.isNotEmpty) return fromField;

    final fromOptions = options
        .where((o) => (o.option ?? '').toLowerCase() == 'color')
        .map((o) => (o.value ?? '').trim())
        .where((v) => v.isNotEmpty)
        .toList(growable: false);
    return fromOptions.isEmpty ? '' : fromOptions.first;
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
    required String productId,
    required double quantity,
    Map<String, String> selectedOptions = const {},
  }) async {
    try {
      final requestedSignature = _optionsSignature(selectedOptions);
      final requestedColor = _extractRequestedColor(selectedOptions);

      final existingResponse = await _client
          .from(CartItemTable().tableName)
          .select('*, cart_item_option(*)')
          .eq(CartItemRow.customerField, userId)
          .eq(CartItemRow.productField, productId);

      final existingItems = existingResponse
          .whereType<Map<String, dynamic>>()
          .map((row) {
            final item = CartItemRow.fromJson(row);
            final optionsData = row['cart_item_option'] as List<dynamic>? ?? [];
            final options = optionsData
                .whereType<Map<String, dynamic>>()
                .map(CartItemOptionRow.fromJson)
                .toList(growable: false);
            return (
              item: item,
              signature: _cartItemOptionsSignature(options),
              color: _extractExistingColor(item, options),
            );
          })
          .toList(growable: false);

      final matching = existingItems.where(
        (e) =>
            e.signature == requestedSignature &&
            e.color.trim().toLowerCase() == requestedColor.trim().toLowerCase(),
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

      final baseInsertPayload = {
        CartItemRow.customerField: userId,
        CartItemRow.productField: productId,
        CartItemRow.quantityField: quantity,
      };

      final insertPayload = {
        ...baseInsertPayload,
        if (requestedColor.isNotEmpty)
          CartItemRow.optionColorField: requestedColor,
      };

      Map<String, dynamic> inserted;
      try {
        inserted = await _client
            .from(CartItemTable().tableName)
            .insert(insertPayload)
            .select()
            .single();
      } on PostgrestException catch (e) {
        if (requestedColor.trim().isEmpty) {
          rethrow;
        }

        debugPrint(
          'cart_item insert with option_color failed; retrying without option_color. '
          'code=${e.code} message=${e.message} details=${e.details}',
        );

        inserted = await _client
            .from(CartItemTable().tableName)
            .insert(baseInsertPayload)
            .select()
            .single();
      }

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
          try {
            await _client.from(CartItemOptionTable().tableName).insert(payload);
          } catch (e) {
            debugPrint(
              'cart_item_option insert failed; keeping cart_item without options. error=$e',
            );
          }
        }
      }

      return cartItem;
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
      debugPrintStack(stackTrace: StackTrace.current);
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
    final cached = _optionsMemo[productId];
    if (cached != null) {
      return cached;
    }

    final future = _fetchProductOptionsUncached(productId);
    _optionsMemo[productId] = future;
    return future;
  }

  Future<List<ProductOptionDefinition>> _fetchProductOptionsUncached(
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
      final valueResponse = optionParameterIds.isNotEmpty
          ? await _client
                .from(ProductOptionValueTable().tableName)
                .select('*')
                .filter(
                  ProductOptionValueRow.optionParameterField,
                  'in',
                  '(${optionParameterIds.map((id) => '"$id"').join(',')})',
                )
          : const [];

      valueResponse
          .whereType<Map<String, dynamic>>()
          .map(ProductOptionValueRow.fromJson)
          .forEach((row) {
            final key = row.optionParameter ?? '__null__';
            valuesByParameter.putIfAbsent(key, () => []).add(row);
          });

      return parameterRows
          .map((row) {
            final parameterId = row.optionParameter ?? row.id;
            final values =
                valuesByParameter[row.optionParameter] ??
                valuesByParameter[row.id] ??
                (row.optionParameter == null
                    ? (valuesByParameter['__null__'] ??
                          <ProductOptionValueRow>[])
                    : <ProductOptionValueRow>[]);

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

  Future<PaymentRow?> createPayment({
    required double amount,
    String? status,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      throw StateError('User not logged in');
    }

    final payment = PaymentRow(
      paymentBy: userId,
      amount: amount,
      status: status ?? 'pending',
    );

    final response = await _client
        .from(PaymentTable().tableName)
        .insert(payment.toJson())
        .select()
        .single();

    return PaymentRow.fromJson(response);
  }

  Future<bool> updatePaymentStatus({
    required String paymentId,
    required String status,
    DateTime? paidAt,
    String? platformId,
    dynamic otherData,
  }) async {
    try {
      final updateData = {
        PaymentRow.statusField: status,
        if (paidAt != null) PaymentRow.paidAtField: paidAt.toIso8601String(),
        if (platformId != null) PaymentRow.platformIdField: platformId,
        if (otherData != null) PaymentRow.otherDataField: otherData,
      };

      await _client
          .from(PaymentTable().tableName)
          .update(updateData)
          .eq(PaymentRow.idField, paymentId);

      return true;
    } catch (e) {
      debugPrint('Error updating payment status: $e');
      return false;
    }
  }
}
