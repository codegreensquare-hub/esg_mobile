import 'package:esg_mobile/core/navigation/green_square_drawer_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:esg_mobile/presentation/screens/auth/signup_terms.screen.dart';
import 'package:esg_mobile/presentation/widgets/layout/green_square_right_drawer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';

/// Step 1 of Green Square sign-up: choose membership type (general vs company).
class SignupTypeScreen extends StatefulWidget {
  const SignupTypeScreen({super.key});

  static const route = '/signup';

  @override
  State<SignupTypeScreen> createState() => _SignupTypeScreenState();
}

class _SignupTypeScreenState extends State<SignupTypeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedType; // 'general' | 'company'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    const disabledBg = Color(0xFFE3E3E3);
    const disabledFg = Color(0xFF9A9A9A);

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
                if (context.canPop()) {
                  context.pop();
                }
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _MemberTypeCard(
                                icon: Icons.person_outline,
                                label: '일반 회원으로 가입',
                                isSelected: _selectedType == 'general',
                                onTap: () =>
                                    setState(() => _selectedType = 'general'),
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _MemberTypeCard(
                                icon: Icons.people_outline,
                                label: '임직원 회원가입',
                                isSelected: _selectedType == 'company',
                                onTap: () =>
                                    setState(() => _selectedType = 'company'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 140,
                          child: VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: Color(0xFFDDDDDD),
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
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.disabled) ? disabledBg : primary,
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? disabledFg
                    : onPrimary,
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: 16),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            onPressed: _selectedType == null
                ? null
                : () => context.push(
                      '${SignupTermsScreen.route}?type=$_selectedType',
                    ),
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
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final bg = isSelected ? const Color(0xFFEAF2EF) : Colors.transparent;
    final border = isSelected ? primary : const Color(0xFFDDDDDD);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
          ),
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
