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

  Future<void> logClick({required String missionId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    if (missionId.isEmpty) return;

    final context = await _resolveMissionContext();

    try {
      await _client.rpc(
        'log_mission_click',
        params: {
          'p_mission': missionId,
          'p_profile_used': context.profileUsed,
          'p_department': context.department,
          'p_sub_department': context.subDepartment,
        },
      );
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
