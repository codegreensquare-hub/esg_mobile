import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountLoggedOutContent extends StatelessWidget {
  const AccountLoggedOutContent({
    super.key,
    required this.onKakaoLogin,
    required this.onAppleLogin,
    required this.onEmailLogin,
    required this.onSignupTap,
  });

  final VoidCallback onKakaoLogin;
  final VoidCallback onAppleLogin;
  final VoidCallback onEmailLogin;
  final VoidCallback onSignupTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                '로그인이 필요한 서비스입니다 :)',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Noto Sans KR',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF355149),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _LoginOptionButton(
                backgroundColor: const Color(0xFFFEE500),
                onPressed: onKakaoLogin,
                icon: SvgPicture.asset(
                  'assets/images/icons/kakao-icon.svg',
                  width: 24,
                  height: 24,
                ),
                label: '카카오 계정으로 로그인',
                labelColor: Colors.black,
              ),
              const SizedBox(height: 12),
              _LoginOptionButton(
                backgroundColor: Colors.black,
                onPressed: onAppleLogin,
                icon: SvgPicture.asset(
                  'assets/images/icons/white-apple-logo.svg',
                  width: 24,
                  height: 24,
                ),
                label: 'Apple로 로그인',
                labelColor: Colors.white,
              ),
              const SizedBox(height: 12),
              _LoginOptionButton(
                backgroundColor: const Color(0xFF355149),
                onPressed: onEmailLogin,
                icon: Icon(
                  Icons.mail_outline,
                  size: 24,
                  color: Colors.white,
                ),
                label: '이메일로 로그인',
                labelColor: Colors.white,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '아직 회원이 아니신가요?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Noto Sans KR',
                      color: const Color(0xFF355149),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onSignupTap,
                    child: Text(
                      '회원가입',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        color: const Color(0xFF656565),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginOptionButton extends StatelessWidget {
  const _LoginOptionButton({
    required this.backgroundColor,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.labelColor,
  });

  final Color backgroundColor;
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 24, height: 24, child: icon),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Noto Sans KR',
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
