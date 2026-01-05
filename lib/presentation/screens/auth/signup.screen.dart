import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/auth/email_confirmation.screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:esg_mobile/presentation/screens/main.screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const route = '/signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  DateTime? _selectedBirthdate;
  bool _isLoadingCompanies = true;
  List<CompanyRow> _companies = const [];
  String? _selectedCompanyId;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoadingCompanies = true;
      _companies = const [];
      _selectedCompanyId = null;
    });

    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from(CompanyTable().tableName)
          .select('${CompanyRow.idField}, ${CompanyRow.nameField}')
          .order(CompanyRow.nameField, ascending: true);

      final companies = (rows as List)
          .whereType<Map<String, dynamic>>()
          .map(CompanyRow.fromJson)
          .where((e) => (e.name ?? '').trim().isNotEmpty)
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _companies = companies;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '회사 목록을 불러오지 못했습니다. 다시 시도해주세요.';
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingCompanies = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final normalizedBirthdate = _selectedBirthdate != null
          ? _selectedBirthdate!.toIso8601String().split('T')[0]
          : null;
      final isVerified = await UserAuthService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        birthdate: normalizedBirthdate,
        company: _selectedCompanyId,
      );
      if (!mounted) return;
      final nextRoute = isVerified
          ? MainScreen.route
          : EmailConfirmationScreen.route;
      context.go(nextRoute);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVerified ? '회원가입이 완료되었습니다.' : '이메일 확인이 완료되면 계속 이용할 수 있습니다.',
          ),
        ),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '회원가입에 실패했습니다. 다시 시도해주세요.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCompanyId,
                    items: _companies
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name ?? ''),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: _isLoadingCompanies
                        ? null
                        : (value) => setState(() => _selectedCompanyId = value),
                    decoration: InputDecoration(
                      labelText: '회사',
                      hintText: _isLoadingCompanies
                          ? '회사 목록 불러오는 중...'
                          : '회사를 선택해주세요',
                      suffixIcon: _isLoadingCompanies
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              tooltip: '회사 목록 새로고침',
                              onPressed: _isSubmitting ? null : _loadCompanies,
                              icon: const Icon(Icons.refresh),
                            ),
                    ),
                    validator: (value) {
                      if (_isLoadingCompanies) {
                        return '회사 목록을 불러오는 중입니다.';
                      }
                      if ((value ?? '').isEmpty) {
                        return '회사를 선택해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: '사용자 이름'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '사용자 이름을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: '이메일'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '비밀번호 확인'),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: '전화번호 (선택)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthdateController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedBirthdate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedBirthdate = picked;
                          _birthdateController.text =
                              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: '생년월일',
                      suffixIcon: _selectedBirthdate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedBirthdate = null;
                                  _birthdateController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _handleSignUp,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('회원가입'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isSubmitting ? null : () => context.pop(),
                    child: const Text('이미 계정이 있나요? 로그인'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
