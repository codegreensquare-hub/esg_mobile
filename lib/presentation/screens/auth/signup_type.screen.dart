import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:esg_mobile/presentation/screens/auth/signup_terms.screen.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';

/// Step 1 of Green Square sign-up: choose membership type (general vs company).
class SignupTypeScreen extends StatefulWidget {
  const SignupTypeScreen({super.key});

  static const route = '/signup';

  @override
  State<SignupTypeScreen> createState() => _SignupTypeScreenState();
}

class _SignupTypeScreenState extends State<SignupTypeScreen> {
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
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(
                          child: _MemberTypeCard(
                            icon: Icons.person_outline,
                            label: '일반 회원으로 가입',
                          ),
                        ),
                        SizedBox(
                          height: 140,
                          child: VerticalDivider(
                            width: 32,
                            thickness: 1,
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                        Expanded(
                          child: _MemberTypeCard(
                            icon: Icons.people_outline,
                            label: '특정 기업/기관 소속 회원가입',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
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
            onPressed: () => context.push(SignupTermsScreen.route),
            child: const Text('다음'),
          ),
        ),
      ),
    );
  }
}

class _MemberTypeCard extends StatelessWidget {
  const _MemberTypeCard({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 72,
                color: primary,
              ),
              const SizedBox(height: 24),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Noto Sans KR',
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
