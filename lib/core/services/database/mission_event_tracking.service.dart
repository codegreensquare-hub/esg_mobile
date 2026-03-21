import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/profile.service.dart';
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

    final context = await _resolveMissionContext();

    try {
      await _client.rpc(
        'log_mission_impression',
        params: {
          'p_mission': missionId,
          'p_profile_used': context.profileUsed,
          'p_department': context.department,
          'p_sub_department': context.subDepartment,
        },
      );
    } catch (_) {}
  }

  Future<void> logClick({
    required String missionId,
    required double cost,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    if (missionId.isEmpty) return;

    final context = await _resolveMissionContext();

    try {
      // Only create a click if all previous clicks have been linked to
      // a participation. Compare counts: if clicks > participations with
      // a linked click, there is already an unlinked click pending.
      final clicks = await _client
          .from('mission_click')
          .select('id')
          .eq('mission', missionId)
          .eq('user', userId);

      final participations = await _client
          .from('mission_participation')
          .select('id')
          .eq('mission', missionId)
          .eq('participated_by', userId)
          .not('mission_click', 'is', null);

      if ((clicks as List).length > (participations as List).length) return;

      await _client.from('mission_click').insert({
        'mission': missionId,
        'user': userId,
        'cost': cost,
        'profile_used': context.profileUsed,
        'department': context.department,
        'sub_department': context.subDepartment,
      });
    } catch (_) {}
  }

  Future<({String? profileUsed, String? department, String? subDepartment})>
  _resolveMissionContext() async {
    final profileService = ProfileService.instance;
    await profileService.initialize();

    var userRow = UserAuthService.instance.userRow;
    if (userRow == null) {
      await UserAuthService.instance.refresh();
      userRow = UserAuthService.instance.userRow;
    }

    return (
      profileUsed: profileService.isMainProfileSelected
          ? null
          : profileService.selectedProfileId,
      department: userRow?.department,
      subDepartment: userRow?.subDepartment,
    );
  }
}
