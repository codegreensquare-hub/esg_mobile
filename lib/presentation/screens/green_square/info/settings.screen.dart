import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/user_settings.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/enums/user_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// App bar and intro text green.
const _appBarGreen = Color(0xFF355148);

/// Switch row text and divider green.
const _textGreen = Color(0xFF355149);

/// Switch track (background) when on.
const _switchTrackGreen = Color(0xFF293F39);

/// Light beige background for settings body.
const _backgroundBeige = Color(0xFFF5F2EE);

class GreenSquareSettingsScreen extends StatefulWidget {
  const GreenSquareSettingsScreen({super.key});

  @override
  State<GreenSquareSettingsScreen> createState() =>
      _GreenSquareSettingsScreenState();
}

class _GreenSquareSettingsScreenState extends State<GreenSquareSettingsScreen> {
  final _authService = UserAuthService.instance;

  late Map<UserSetting, bool> _settings;
  late Future<Map<UserSetting, bool>> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_handleAuthChanged);
    _settings = _buildInitialSettings();
    _settingsFuture = _createSettingsFuture();
  }

  @override
  void dispose() {
    _authService.removeListener(_handleAuthChanged);
    super.dispose();
  }

  Future<Map<UserSetting, bool>> _createSettingsFuture() async {
    try {
      final resolvedSettings = await UserSettingsService.instance
          .getResolvedSettings(userId: _authService.currentUser?.id);
      _settings = resolvedSettings;
      return resolvedSettings;
    } catch (_) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('설정 정보를 불러오지 못했습니다.')),
          );
        });
      }
      return _settings;
    }
  }

  Map<UserSetting, bool> _buildInitialSettings() {
    final cachedSettings = UserSettingsService.instance.getCachedSettings(
      userId: _authService.currentUser?.id,
    );

    return {
      for (final setting in UserSetting.values)
        setting: cachedSettings[setting] ?? true,
    };
  }

  Future<void> _updateSetting(UserSetting setting, bool value) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 후 설정을 저장할 수 있습니다.')),
      );
      return;
    }

    final previousValue = _settings[setting] ?? true;

    setState(() {
      _settings = {
        ..._settings,
        setting: value,
      };
      _settingsFuture = Future.value(_settings);
    });

    try {
      await UserSettingsService.instance.upsertSetting(
        userId: userId,
        setting: setting,
        value: value,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _settings = {
          ..._settings,
          setting: previousValue,
        };
        _settingsFuture = Future.value(_settings);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정을 저장하지 못했습니다.')),
      );
    }
  }

  void _handleAuthChanged() {
    setState(() {
      _settings = _buildInitialSettings();
      _settingsFuture = _createSettingsFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _backgroundBeige,
      appBar: AppBar(
        backgroundColor: _appBarGreen,
        foregroundColor: Colors.white,
        title: Text(
          '설정',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w400,
            color: Colors.white,
            fontFamily: 'Noto Sans KR',
          ),
        ),
      ),
      body: FutureBuilder<Map<UserSetting, bool>>(
        future: _settingsFuture,
        initialData: _settings,
        builder: (context, snapshot) {
          final settings = snapshot.data ?? _settings;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branding section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      SvgPicture.network(
                        getImageLink(
                          bucket.asset,
                          asset.greensquareLogo,
                          folderPath: assetFolderPath[asset.greensquareLogo],
                        ),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Builder(
                          builder: (context) {
                            final screenWidth = MediaQuery.sizeOf(
                              context,
                            ).width;
                            final dividerWidth = screenWidth > 0
                                ? (78 * (screenWidth / 375)).clamp(
                                    78.0,
                                    120.0,
                                  )
                                : 78.0;
                            return Container(
                              width: dividerWidth,
                              height: 1,
                              color: _textGreen.withValues(alpha: 0.4),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '혜택, 미션, 공지, 마일리지 소멸 안내 등\n중요한 알림을 받을 수 있습니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: _appBarGreen,
                          height: 1.4,
                          fontFamily: 'Noto Sans KR',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Settings list
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 12, 0),
                  child: Column(
                    children: [
                      _SettingRow(
                        title: '마케팅 정보 수신 동의',
                        description: '이벤트, 혜택, 프로모션 등의 마케팅 정보',
                        value:
                            settings[UserSetting
                                .receive_marketing_information_consent] ??
                            true,
                        trackColor: _switchTrackGreen,
                        onChanged: (value) => _updateSetting(
                          UserSetting.receive_marketing_information_consent,
                          value,
                        ),
                      ),
                      _SettingRow(
                        title: '개인정보 제3자 제공 동의',
                        description:
                            '기관 협력 미션 참여 시 정보 제공됨\n(미동의 시 일부 미션 참여가 제한될 수 있습니다)',
                        value:
                            settings[UserSetting
                                .provide_personal_information_to_third_parties_consent] ??
                            true,
                        trackColor: _switchTrackGreen,
                        onChanged: (value) => _updateSetting(
                          UserSetting
                              .provide_personal_information_to_third_parties_consent,
                          value,
                        ),
                      ),
                      _SettingRow(
                        title: '미션',
                        description: '신규 미션 생성, 마감 임박 미션 안내 등',
                        value:
                            settings[UserSetting.missions_notification] ?? true,
                        trackColor: _switchTrackGreen,
                        onChanged: (value) => _updateSetting(
                          UserSetting.missions_notification,
                          value,
                        ),
                      ),
                      _SettingRow(
                        title: '마일리지',
                        description: '적립 마일리지, 당월 소멸 마일리지 안내 등',
                        value:
                            settings[UserSetting.award_points_notification] ??
                            true,
                        trackColor: _switchTrackGreen,
                        onChanged: (value) => _updateSetting(
                          UserSetting.award_points_notification,
                          value,
                        ),
                      ),
                      _SettingRow(
                        title: '스토리',
                        description: '신규 스토리 생성 안내, 인기 스토리 알림 등',
                        value:
                            settings[UserSetting.stories_notification] ?? true,
                        trackColor: _switchTrackGreen,
                        onChanged: (value) => _updateSetting(
                          UserSetting.stories_notification,
                          value,
                        ),
                      ),
                      _SettingRow(
                        title: '공지사항',
                        description: '주요 공지사항 안내, 앱 업데이트 안내 등',
                        value: settings[UserSetting.notices] ?? true,
                        trackColor: _switchTrackGreen,
                        onChanged: (value) =>
                            _updateSetting(UserSetting.notices, value),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.description,
    required this.value,
    required this.trackColor,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final Color trackColor;
  final ValueChanged<bool> onChanged;

  static const _textColor = _textGreen; // #355149
  static const _fontFamily = 'Noto Sans KR';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return Colors.grey;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) return trackColor;
            return Colors.grey.withValues(alpha: 0.5);
          }),
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.fromLTRB(0, 6, 0, 6),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: _textColor,
            fontFamily: _fontFamily,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: _textColor,
              height: 1.35,
              fontFamily: _fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
