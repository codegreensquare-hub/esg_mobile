import 'package:supabase_flutter/supabase_flutter.dart';

class MissionEventTrackingService {
  MissionEventTrackingService._internal({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static final MissionEventTrackingService _instance =
      MissionEventTrackingService._internal();

  static MissionEventTrackingService get instance => _instance;

  final SupabaseClient _client;

  Future<void> logImpression({required String missionId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    if (missionId.isEmpty) return;

    try {
      await _client.rpc(
        'log_mission_impression',
        params: {
          'p_mission': missionId,
        },
      );
    } catch (_) {}
  }

  Future<void> logClick({required String missionId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    if (missionId.isEmpty) return;

    try {
      await _client.rpc(
        'log_mission_click',
        params: {
          'p_mission': missionId,
        },
      );
    } catch (_) {}
  }
}
