import 'package:flutter/foundation.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserShippingAddressService {
  UserShippingAddressService._();
  static final UserShippingAddressService instance =
      UserShippingAddressService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<UserShippingAddressRow>> fetchAddresses(String userId) async {
    try {
      final response = await _client
          .from(UserShippingAddressTable().tableName)
          .select('*')
          .eq(UserShippingAddressRow.addressByField, userId)
          .order(UserShippingAddressRow.createdAtField, ascending: false);

      return response
          .map((data) => UserShippingAddressRow.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching shipping addresses: $e');
      return [];
    }
  }

  Future<UserShippingAddressRow?> createAddress({
    required String userId,
    required String name,
    required String recipientName,
    required String phoneNumber,
    required String address,
    String? detailedAddress,
    String? requestsForDelivery,
    bool reusableBoxesAreOkay = false,
  }) async {
    try {
      final response = await _client
          .from(UserShippingAddressTable().tableName)
          .insert({
            UserShippingAddressRow.addressByField: userId,
            UserShippingAddressRow.nameField: name,
            UserShippingAddressRow.recipientNameField: recipientName,
            UserShippingAddressRow.phoneNumberField: phoneNumber,
            UserShippingAddressRow.addressField: address,
            UserShippingAddressRow.detailedAddressField: detailedAddress,
            UserShippingAddressRow.requestsForDeliveryField:
                requestsForDelivery,
            UserShippingAddressRow.reusableBoxesAreOkayField:
                reusableBoxesAreOkay,
          })
          .select()
          .single();

      return UserShippingAddressRow.fromJson(response);
    } catch (e) {
      debugPrint('Error creating shipping address: $e');
      return null;
    }
  }

  Future<UserShippingAddressRow?> updateAddress({
    required String addressId,
    required String name,
    required String recipientName,
    required String phoneNumber,
    required String address,
    String? detailedAddress,
    String? requestsForDelivery,
    bool reusableBoxesAreOkay = false,
  }) async {
    try {
      final response = await _client
          .from(UserShippingAddressTable().tableName)
          .update({
            UserShippingAddressRow.nameField: name,
            UserShippingAddressRow.recipientNameField: recipientName,
            UserShippingAddressRow.phoneNumberField: phoneNumber,
            UserShippingAddressRow.addressField: address,
            UserShippingAddressRow.detailedAddressField: detailedAddress,
            UserShippingAddressRow.requestsForDeliveryField:
                requestsForDelivery,
            UserShippingAddressRow.reusableBoxesAreOkayField:
                reusableBoxesAreOkay,
          })
          .eq(UserShippingAddressRow.idField, addressId)
          .select()
          .single();

      return UserShippingAddressRow.fromJson(response);
    } catch (e) {
      debugPrint('Error updating shipping address: $e');
      return null;
    }
  }

  Future<String?> fetchDefaultAddressId(String userId) async {
    try {
      final response = await _client
          .from(UserTable().tableName)
          .select(UserRow.defaultShippingAddressField)
          .eq(UserRow.idField, userId)
          .maybeSingle();

      return response?[UserRow.defaultShippingAddressField] as String?;
    } catch (e) {
      debugPrint('Error fetching default shipping address: $e');
      return null;
    }
  }

  Future<void> setDefaultAddress({
    required String userId,
    String? addressId,
  }) async {
    try {
      await _client
          .from(UserTable().tableName)
          .update({
            UserRow.defaultShippingAddressField: addressId,
          })
          .eq(UserRow.idField, userId);
    } catch (e) {
      debugPrint('Error setting default shipping address: $e');
      rethrow;
    }
  }
}
