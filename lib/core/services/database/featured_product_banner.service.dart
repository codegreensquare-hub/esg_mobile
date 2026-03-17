import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeaturedProductBannerService {
  FeaturedProductBannerService._internal({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  static final FeaturedProductBannerService _instance =
      FeaturedProductBannerService._internal();

  static FeaturedProductBannerService get instance => _instance;

  final SupabaseClient _client;
  final FeaturedProductBannerTable _table = FeaturedProductBannerTable();

  PostgrestQueryBuilder get _baseQuery => _client.from(_table.tableName);

  Future<List<FeaturedProductBannerRow>> fetchActiveBanners({
    required String appType,
  }) async {
    final response = await _baseQuery
        .select()
        .eq(FeaturedProductBannerRow.appTypeField, appType)
        .eq(FeaturedProductBannerRow.isActiveField, true)
        .order(FeaturedProductBannerRow.displayOrderField, ascending: true);

    return (response as List)
        .map(
          (row) => FeaturedProductBannerRow.fromJson(
            row as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);
  }
}

