import 'package:flutter/material.dart';

/// App bar and intro text green.
const _appBarGreen = Color(0xFF355148);

/// Switch row text and divider green.
const _textGreen = Color(0xFF355149);

/// Switch track (background) when on.
const _switchTrackGreen = Color(0xFF293F39);

/// Light beige background for settings body.
const _backgroundBeige = Color(0xFFF5F2EE);

const _greenSquareLogoAsset = 'assets/images/screen/settings/green_square_logo.png';

class GreenSquareSettingsScreen extends StatefulWidget {
  const GreenSquareSettingsScreen({super.key});

  @override
  State<GreenSquareSettingsScreen> createState() =>
      _GreenSquareSettingsScreenState();
}

class _GreenSquareSettingsScreenState extends State<GreenSquareSettingsScreen> {
  bool _marketing = true;
  bool _thirdPartyPrivacy = true;
  bool _missions = true;
  bool _mileage = true;
  bool _stories = true;
  bool _announcements = true;

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Branding section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
              child: Column(
                children: [
                  Image.asset(
                    _greenSquareLogoAsset,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.sizeOf(context).width;
                        final dividerWidth = screenWidth > 0
                            ? (78 * (screenWidth / 375)).clamp(78.0, 120.0)
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _SettingRow(
                    title: '마케팅 정보 수신 동의',
                    description: '이벤트, 혜택, 프로모션 등의 마케팅 정보',
                    value: _marketing,
                    trackColor: _switchTrackGreen,
                    onChanged: (v) => setState(() => _marketing = v),
                  ),
                  const SizedBox(height: 24),
                  _SettingRow(
                    title: '개인정보 제3자 제공 동의',
                    description:
                        '기관 협력 미션 참여 시 정보 제공됨\n(미동의 시 일부 미션 참여가 제한될 수 있습니다)',
                    value: _thirdPartyPrivacy,
                    trackColor: _switchTrackGreen,
                    onChanged: (v) => setState(() => _thirdPartyPrivacy = v),
                  ),
                  const SizedBox(height: 24),
                  _SettingRow(
                    title: '미션',
                    description: '신규 미션 생성, 마감 임박 미션 안내 등',
                    value: _missions,
                    trackColor: _switchTrackGreen,
                    onChanged: (v) => setState(() => _missions = v),
                  ),
                  const SizedBox(height: 24),
                  _SettingRow(
                    title: '마일리지',
                    description: '적립 마일리지, 당월 소멸 마일리지 안내 등',
                    value: _mileage,
                    trackColor: _switchTrackGreen,
                    onChanged: (v) => setState(() => _mileage = v),
                  ),
                  const SizedBox(height: 24),
                  _SettingRow(
                    title: '스토리',
                    description: '신규 스토리 생성 안내, 인기 스토리 알림 등',
                    value: _stories,
                    trackColor: _switchTrackGreen,
                    onChanged: (v) => setState(() => _stories = v),
                  ),
                  const SizedBox(height: 24),
                  _SettingRow(
                    title: '공지사항',
                    description: '주요 공지사항 안내, 앱 업데이트 안내 등',
                    value: _announcements,
                    trackColor: _switchTrackGreen,
                    onChanged: (v) => setState(() => _announcements = v),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                  fontFamily: _fontFamily,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: _textColor,
                  height: 1.35,
                  fontFamily: _fontFamily,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Theme(
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
          child: Switch(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
