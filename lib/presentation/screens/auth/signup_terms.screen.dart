import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:esg_mobile/presentation/screens/green_square/info/terms.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/privacy_policy.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_form.screen.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';

/// Step 2 of Green Square sign-up: terms and conditions agreement.
class SignupTermsScreen extends StatefulWidget {
  const SignupTermsScreen({super.key});

  static const route = '/signup/terms';

  @override
  State<SignupTermsScreen> createState() => _SignupTermsScreenState();
}

class _SignupTermsScreenState extends State<SignupTermsScreen> {
  bool _agreeAll = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  String get _typeParam {
    final uri = GoRouterState.of(context).uri;
    return uri.queryParameters['type'] ?? 'general';
  }

  void _setAgreeAll(bool value) {
    setState(() {
      _agreeAll = value;
      _agreeTerms = value;
      _agreePrivacy = value;
    });
  }

  void _updateAgreeTerms(bool? value) {
    setState(() {
      _agreeTerms = value ?? false;
      _agreeAll = _agreeTerms && _agreePrivacy;
    });
  }

  void _updateAgreePrivacy(bool? value) {
    setState(() {
      _agreePrivacy = value ?? false;
      _agreeAll = _agreeTerms && _agreePrivacy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          CodeGreenTopHeader(
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
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
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
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
                      '서비스를 이용하려면 약관 동의가 필요합니다.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        _AgreeRow(
                          label: '전체 동의하기',
                          value: _agreeAll,
                          onChanged: _setAgreeAll,
                          isMaster: true,
                        ),
                        const SizedBox(height: 20),
                        _AgreeRow(
                          label: '[필수] 코드그린 스퀘어 서비스 이용약관 동의',
                          value: _agreeTerms,
                          onChanged: _updateAgreeTerms,
                          viewLabel: '보기',
                          onView: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GreenSquareTermsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 0),
                        _AgreeRow(
                          label: '[필수] 개인정보 수집 및 이용 동의',
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
            onPressed: (_agreeTerms && _agreePrivacy)
                ? () => context.push(
                      '${SignupFormScreen.route}?type=$_typeParam',
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
            child: Icon(
              Icons.check,
              size: 18,
              color: checkColor,
            ),
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
