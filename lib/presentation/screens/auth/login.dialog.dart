import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/utils/auth_exception_message_ko.dart';
import 'package:esg_mobile/presentation/screens/auth/email_confirmation.screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result when the login dialog is closed.
/// - [true]: login succeeded (email verified)
/// - [false]: login succeeded but email not yet verified
/// - [null]: dialog dismissed without logging in
typedef LoginDialogResult = bool?;

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  static const _buttonGreen = Color(0xFF355149);
  static const _borderGrey = Color(0xFFE0E0E0);
  static const _labelGrey = Color(0xFF424242);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _close(LoginDialogResult result) {
    Navigator.of(context).pop(result);
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final isVerified = await UserAuthService.instance.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      _close(isVerified);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVerified
                ? '로그인되었습니다.'
                : '이메일 인증이 필요합니다. 받은 편지함을 확인해주세요.',
          ),
        ),
      );
      if (!isVerified) {
        context.go(EmailConfirmationScreen.route);
      }
    } on AuthException catch (e) {
      setState(
        () => _error = authExceptionMessageKo(
          e,
          genericFallback: '로그인에 실패했습니다. 다시 시도해주세요.',
        ),
      );
    } catch (e) {
      setState(() => _error = '로그인에 실패했습니다. 다시 시도해주세요.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // White content area (no rounding on top)
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        '로그인',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w800,
                              color: _labelGrey,
                            ),
                      ),
                      const SizedBox(height: 28),
                      // Email label
                      Text(
                        '이메일',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              color: _labelGrey,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: _borderGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: _borderGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: _buttonGreen,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password label
                      Text(
                        '비밀번호',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              color: _labelGrey,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: _borderGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: _borderGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: _buttonGreen,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontFamily: 'Noto Sans KR',
                              ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Login button
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: _buttonGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  '로그인',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontFamily: 'Noto Sans KR',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Black footer with close
            Material(
              color: Colors.black,
              child: InkWell(
                onTap: () => _close(null),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.close, size: 20, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '닫기',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
