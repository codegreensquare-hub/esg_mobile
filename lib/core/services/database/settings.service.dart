import 'package:esg_mobile/core/constants/settings.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._();
  SettingsService._();

  final SupabaseClient _client = Supabase.instance.client;

  double? _cachedBaseDiscountRate;
  Future<double>? _baseDiscountRateInFlight;

  double get cachedBaseDiscountRate => _cachedBaseDiscountRate ?? 0.0;

  Future<double> getBaseDiscountRate({bool forceRefresh = false}) {
    if (!forceRefresh && _cachedBaseDiscountRate != null) {
      return Future.value(_cachedBaseDiscountRate);
    }

    final inFlight = _baseDiscountRateInFlight;
    if (!forceRefresh && inFlight != null) {
      return inFlight;
    }

    final future = _fetchBaseDiscountRate();
    _baseDiscountRateInFlight = future;
    return future.whenComplete(() {
      if (identical(_baseDiscountRateInFlight, future)) {
        _baseDiscountRateInFlight = null;
      }
    });
  }

  Future<double> _fetchBaseDiscountRate() async {
    final row = await _client
        .from(SettingTable().tableName)
        .select()
        .eq(SettingRow.idField, setting.baseDiscountRate)
        .maybeSingle();

    final value = row == null
        ? 0.0
        : (SettingRow.fromJson(row).valueNum ?? 0.0);
    _cachedBaseDiscountRate = value;
    return value;
  }
}
