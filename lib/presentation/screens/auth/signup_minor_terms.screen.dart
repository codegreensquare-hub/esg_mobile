import 'package:esg_mobile/core/navigation/green_square_drawer_navigation.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_form.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_guardian_form.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/privacy_policy.screen.dart';
import 'package:esg_mobile/presentation/widgets/layout/green_square_right_drawer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Minor signup sub-flow — Step 1: guardian consent terms.
/// Shown when the signing-up user is under 14 years old.
class SignupMinorTermsScreen extends StatefulWidget {
  const SignupMinorTermsScreen({super.key, required this.formData});

  static const route = '/signup/minor-terms';

  final SignupFormData formData;

  @override
  State<SignupMinorTermsScreen> createState() => _SignupMinorTermsScreenState();
}

class _SignupMinorTermsScreenState extends State<SignupMinorTermsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _agreeAll = false;
  bool _agreeChildPrivacy = false;
  bool _agreePrivacy = false;
  bool _agreeMarketing = false;

  void _setAgreeAll(bool value) {
    setState(() {
      _agreeAll = value;
      _agreeChildPrivacy = value;
      _agreePrivacy = value;
      _agreeMarketing = value;
    });
  }

  void _updateAgreeChildPrivacy(bool? value) {
    setState(() {
      _agreeChildPrivacy = value ?? false;
      _agreeAll = _agreeChildPrivacy && _agreePrivacy && _agreeMarketing;
    });
  }

  void _updateAgreePrivacy(bool? value) {
    setState(() {
      _agreePrivacy = value ?? false;
      _agreeAll = _agreeChildPrivacy && _agreePrivacy && _agreeMarketing;
    });
  }

  void _updateAgreeMarketing(bool? value) {
    setState(() {
      _agreeMarketing = value ?? false;
      _agreeAll = _agreeChildPrivacy && _agreePrivacy && _agreeMarketing;
    });
  }

  bool get _canProceed => _agreeChildPrivacy && _agreePrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      endDrawer: GreenSquareRightDrawer(
        onSelect: (destination) =>
            navigateFromGreenSquareDrawer(context, destination),
      ),
      body: CustomScrollView(
        slivers: [
          CodeGreenTopHeader(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                if (context.canPop()) context.pop();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: '메뉴',
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text(
                      '코드그린 스퀘어 회원가입',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Text(
                      '만 14세 미만 회원가입의 경우,\n(보호자)법정대리인 동의가 필요합니다.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF355148),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AgreeRow(
                          label: '전체 동의하기',
                          value: _agreeAll,
                          onChanged: _setAgreeAll,
                          isMaster: true,
                        ),
                        const SizedBox(height: 20),
                        _AgreeRow(
                          label: '[필수] 만 14세 미만 아동의 개인정보 처리 동의',
                          value: _agreeChildPrivacy,
                          onChanged: _updateAgreeChildPrivacy,
                          viewLabel: '보기',
                          onView: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const GreenSquarePrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _AgreeRow(
                          label: '[필수] 그린스퀘어 개인정보 수집 및 이용',
                          value: _agreePrivacy,
                          onChanged: _updateAgreePrivacy,
                          viewLabel: '보기',
                          onView: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const GreenSquarePrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _AgreeRow(
                          label: '[선택] 마케팅 정보 수신 동의',
                          value: _agreeMarketing,
                          onChanged: _updateAgreeMarketing,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _canProceed
                ? () => context.push(
                      SignupGuardianFormScreen.route,
                      extra: widget.formData,
                    )
                : null,
            child: const Text('다음'),
          ),
        ),
      ),
    );
  }
}

class _AgreeRow extends StatelessWidget {
  const _AgreeRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isMaster = false,
    this.viewLabel,
    this.onView,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isMaster;
  final String? viewLabel;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isActive = value;
    final Color bgColor =
        isActive ? const Color(0xFF355149) : const Color(0xFFDFDFDF);
    final Color checkColor =
        isActive ? Colors.white : const Color(0xFF999999);
    final Color textColor =
        isActive ? const Color(0xFF0B3010) : const Color(0xFF999999);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bgColor,
            shape: isMaster ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isMaster ? null : BorderRadius.circular(6),
          ),
          child: InkWell(
            onTap: () => onChanged(!value),
            customBorder: isMaster
                ? const CircleBorder()
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
            child: Icon(Icons.check, size: 18, color: checkColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onChanged(!value),
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Noto Sans KR',
                fontWeight: isMaster ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
        if (viewLabel != null && onView != null)
          TextButton(
            onPressed: onView,
            child: Text(
              viewLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Noto Sans KR',
                fontWeight: FontWeight.w500,
                color: const Color(0xFF999999),
                decoration: TextDecoration.underline,
                decorationThickness: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}
