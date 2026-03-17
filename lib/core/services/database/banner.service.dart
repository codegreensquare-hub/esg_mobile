import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BannerService {
  BannerService._internal({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  static final BannerService _instance = BannerService._internal();

  static BannerService get instance => _instance;

  final SupabaseClient _client;
  final BannerTable _bannerTable = BannerTable();

  PostgrestQueryBuilder get _baseQuery => _client.from(_bannerTable.tableName);

  Future<List<BannerRow>> fetchActiveBanners({
    required String appType,
  }) async {
    final response = await _baseQuery
        .select()
        .eq(BannerRow.appTypeField, appType)
        .eq(BannerRow.isActiveField, true)
        .order(BannerRow.displayOrderField, ascending: true);

    return (response as List)
        .map(
          (row) => BannerRow.fromJson(row as Map<String, dynamic>),
        )
        .toList(growable: false);
  }
}

