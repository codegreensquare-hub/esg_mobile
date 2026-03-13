import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/auth/email_confirmation.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_minor_terms.screen.dart';
import 'package:esg_mobile/presentation/screens/main.screen.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data collected in the signup form, passed forward when the user is under 14.
class SignupFormData {
  const SignupFormData({
    required this.email,
    required this.password,
    required this.username,
    this.phone,
    this.birthdate,
    this.company,
  });

  final String email;
  final String password;
  final String username;
  final String? phone;
  final String? birthdate;
  final String? company;
}

/// Step 3 of Green Square sign-up: personal info form and submit.
class SignupFormScreen extends StatefulWidget {
  const SignupFormScreen({super.key});

  static const route = '/signup/form';

  @override
  State<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends State<SignupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  DateTime? _selectedBirthdate;
  String? _gender;
  bool _isLoadingCompanies = true;
  List<CompanyRow> _companies = const [];
  String? _selectedCompanyId;
  bool _isSubmitting = false;
  String? _error;

  bool _isCompanyType(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    return uri.queryParameters['type'] == 'company';
  }

  @override
  void initState() {
    super.initState();
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
      setState(() => _companies = companies);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '회사 목록을 불러오지 못했습니다.');
    } finally {
      if (mounted) setState(() => _isLoadingCompanies = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  bool _isUnder14() {
    if (_selectedBirthdate == null) return false;
    final today = DateTime.now();
    final turning14 = DateTime(
      _selectedBirthdate!.year + 14,
      _selectedBirthdate!.month,
      _selectedBirthdate!.day,
    );
    return today.isBefore(turning14);
  }

  SignupFormData _buildFormData() {
    final normalizedBirthdate = _selectedBirthdate != null
        ? _selectedBirthdate!.toIso8601String().split('T')[0]
        : null;
    return SignupFormData(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      birthdate: normalizedBirthdate,
      company: _isCompanyType(context) ? _selectedCompanyId : null,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isUnder14()) {
      context.push(SignupMinorTermsScreen.route, extra: _buildFormData());
      return;
    }

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
        username: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        birthdate: normalizedBirthdate,
        company: _isCompanyType(context) ? _selectedCompanyId : null,
      );
      if (!mounted) return;
      context.go(isVerified ? MainScreen.route : EmailConfirmationScreen.route);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVerified
                ? '회원가입이 완료되었습니다.'
                : '이메일 확인이 완료되면 계속 이용할 수 있습니다.',
          ),
        ),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '회원가입에 실패했습니다. 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static bool _isValidName(String? s) {
    if (s == null || s.trim().isEmpty) return false;
    return s.trim().length >= 2;
  }

  InputDecoration _fieldDecoration(
    ThemeData theme, {
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    if (_isCompanyType(context) &&
        _companies.isEmpty &&
        !_isLoadingCompanies) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCompanies());
    }

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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            '코드그린 스퀘어 회원가입',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w800,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '이메일',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Noto Sans KR',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _fieldDecoration(
                                  theme,
                                  hint: '이메일 입력',
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _ClearSuffixButton(
                                        onPressed: () => _emailController.clear(),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '인증',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: onPrimary,
                                            fontFamily: 'Noto Sans KR',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                                validator: (v) {
                                  final t = v?.trim() ?? '';
                                  if (t.isEmpty) {
                                    return '이메일을 입력해주세요.';
                                  }
                                  if (!_emailRegex.hasMatch(t)) {
                                    return '이메일 형식이 아닙니다';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '비밀번호',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _fieldDecoration(
                              theme,
                              hint: '8자이상 문자, 숫자, 특수문자를 조합해서 입력해주세요',
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ClearSuffixButton(
                                    onPressed: () =>
                                        _passwordController.clear(),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return '비밀번호를 입력해주세요.';
                              }
                              if (v.length < 8) {
                                return '비밀번호는 8자 이상이어야 합니다.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '비밀번호 확인',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: _fieldDecoration(
                              theme,
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ClearSuffixButton(
                                    onPressed: () =>
                                        _confirmPasswordController.clear(),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                            validator: (v) {
                              if (v != _passwordController.text) {
                                return '비밀번호가 일치하지 않습니다.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '이름',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: _fieldDecoration(
                              theme,
                              hint: '홍길동',
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ClearSuffixButton(
                                    onPressed: () => _nameController.clear(),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                            validator: (v) {
                              if (!_isValidName(v)) {
                                return '올바른 이름을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '휴대폰 번호',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _fieldDecoration(
                              theme,
                              hint: 'xxx-xxxx-xxxx',
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ClearSuffixButton(
                                    onPressed: () => _phoneController.clear(),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '생년월일 및 성별',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _birthdateController,
                                  readOnly: true,
                                  decoration: _fieldDecoration(
                                    theme,
                                    hint: 'YYMMDD',
                                  ),
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _selectedBirthdate ?? DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedBirthdate = picked;
                                        _birthdateController.text =
                                            '${picked.year.toString().substring(2)}${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}';
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '-',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _gender,
                                  decoration: _fieldDecoration(
                                    theme,
                                    hint: '0 *******',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'M',
                                      child: Text('0 *******'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'F',
                                      child: Text('1 *******'),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _gender = v),
                                ),
                              ),
                            ],
                          ),
                          if (_isCompanyType(context)) ...[
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCompanyId,
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
                                  : (v) =>
                                      setState(() => _selectedCompanyId = v),
                              decoration: InputDecoration(
                                labelText: '회사',
                                hintText: _isLoadingCompanies
                                    ? '불러오는 중...'
                                    : '회사를 선택해주세요',
                              ),
                              validator: (v) {
                                if (_isCompanyType(context) &&
                                    (v == null || v.isEmpty)) {
                                  return '회사를 선택해주세요.';
                                }
                                return null;
                              },
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
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
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('제출'),
          ),
        ),
      ),
    );
  }
}

class _ClearSuffixButton extends StatelessWidget {
  const _ClearSuffixButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFDCDCDC),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            size: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
