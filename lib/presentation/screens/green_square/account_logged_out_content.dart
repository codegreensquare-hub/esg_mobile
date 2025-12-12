import 'package:flutter/material.dart';

class AccountLoggedOutContent extends StatefulWidget {
  const AccountLoggedOutContent({
    super.key,
    required this.onLogin,
    required this.onSignupTap,
  });

  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback onSignupTap;

  @override
  State<AccountLoggedOutContent> createState() =>
      _AccountLoggedOutContentState();
}

class _AccountLoggedOutContentState extends State<AccountLoggedOutContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.onLogin(email, password);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline, size: 64, color: cs.primary),
              const SizedBox(height: 16),
              Text(
                '로그인이 필요합니다',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '그린 스퀘어의 마일리지와 미션을 확인하려면 로그인 또는 회원가입을 진행해주세요.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: '이메일'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(_submitting ? '로그인 중...' : '로그인'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _submitting ? null : widget.onSignupTap,
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
