import 'package:esg_mobile/data/models/supabase/enums/user_setting.dart';
import 'package:esg_mobile/data/models/supabase/tables/user_setting_detail.dart';
import 'package:esg_mobile/data/models/supabase/tables/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSettingsService {
  UserSettingsService._();

  static final UserSettingsService instance = UserSettingsService._();

  final SupabaseClient _client = Supabase.instance.client;

  Map<UserSetting, bool> cachedDefaults = {};
  final Map<String, Map<UserSetting, bool>> _cachedUserSettings = {};

  Map<UserSetting, bool> getCachedSettings({String? userId}) {
    if (userId == null) {
      return {...cachedDefaults};
    }

    return {
      ...cachedDefaults,
      ...?_cachedUserSettings[userId],
    };
  }

  Future<Map<UserSetting, bool>> getResolvedSettings({String? userId}) async {
    final defaultRows = await _client
        .from(UserSettingDetailTable().tableName)
        .select();

    final defaults = defaultRows
        .map(UserSettingDetailRow.fromJson)
        .fold<Map<UserSetting, bool>>({}, (settings, row) {
          settings[row.id] = row.defaultValue;
          return settings;
        });

    cachedDefaults = {
      ...cachedDefaults,
      ...defaults,
    };

    if (userId == null) {
      return {...defaults};
    }

    final userRows = await _client
        .from(UserSettingsTable().tableName)
        .select()
        .eq(UserSettingsRow.userField, userId);

    final resolvedSettings = userRows.map(UserSettingsRow.fromJson).fold<Map<UserSetting, bool>>(
      {...defaults},
      (settings, row) {
        settings[row.setting] = row.value;
        return settings;
      },
    );

    _cachedUserSettings[userId] = {
      for (final entry in resolvedSettings.entries) entry.key: entry.value,
    };

    return resolvedSettings;
  }

  Future<void> upsertSetting({
    required String userId,
    required UserSetting setting,
    required bool value,
  }) async {
    await _client.from(UserSettingsTable().tableName).upsert(
      {
        UserSettingsRow.userField: userId,
        UserSettingsRow.settingField: setting.name,
        UserSettingsRow.valueField: value,
      },
      onConflict:
          '${UserSettingsRow.userField},${UserSettingsRow.settingField}',
    );

    _cachedUserSettings[userId] = {
      ...getCachedSettings(userId: userId),
      setting: value,
    };
  }
}
