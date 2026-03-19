import 'dart:async';

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
  bool _isCompanySignup = false;
  bool _isResolvingCompany = false;
  String? _resolvedCompanyId;
  String? _resolvedCompanyName;
  String? _companyDomainError;
  bool _isSubmitting = false;
  String? _error;
  Timer? _domainDebounce;
  bool _submitEnabled = false;

  bool _isCompanyType(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    return uri.queryParameters['type'] == 'company';
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_handleEmailChanged);
    _emailController.addListener(_recomputeSubmitEnabled);
    _passwordController.addListener(_recomputeSubmitEnabled);
    _confirmPasswordController.addListener(_recomputeSubmitEnabled);
    _nameController.addListener(_recomputeSubmitEnabled);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextIsCompany = _isCompanyType(context);
    if (nextIsCompany != _isCompanySignup) {
      setState(() {
        _isCompanySignup = nextIsCompany;
        _resolvedCompanyId = null;
        _resolvedCompanyName = null;
        _companyDomainError = null;
      });
      if (nextIsCompany) {
        _resolveCompanyFromEmail(_emailController.text.trim());
      }
    }
  }

  @override
  void dispose() {
    _domainDebounce?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  void _handleEmailChanged() {
    if (!_isCompanySignup) return;
    final email = _emailController.text.trim();
    if (!_emailRegex.hasMatch(email)) {
      if (_companyDomainError != null ||
          _resolvedCompanyId != null ||
          _resolvedCompanyName != null) {
        setState(() {
          _companyDomainError = null;
          _resolvedCompanyId = null;
          _resolvedCompanyName = null;
        });
      }
      return;
    }

    _domainDebounce?.cancel();
    _domainDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _resolveCompanyFromEmail(email),
    );
  }

  static String? _extractDomain(String email) {
    final at = email.lastIndexOf('@');
    if (at < 0 || at == email.length - 1) return null;
    return email.substring(at + 1).trim().toLowerCase();
  }

  Future<void> _resolveCompanyFromEmail(String email) async {
    if (!_isCompanySignup) return;
    final domain = _extractDomain(email);
    if (domain == null || domain.isEmpty) return;

    setState(() {
      _isResolvingCompany = true;
      _companyDomainError = null;
      _resolvedCompanyId = null;
      _resolvedCompanyName = null;
    });

    try {
      final client = Supabase.instance.client;
      final domainRow = await client
          .from(CompanyEmailDomainTable().tableName)
          .select(
            '${CompanyEmailDomainRow.companyIdField}, ${CompanyEmailDomainRow.domainField}',
          )
          .eq(CompanyEmailDomainRow.domainField, domain)
          .eq(CompanyEmailDomainRow.isActiveField, true)
          .maybeSingle();

      if (!mounted) return;

      if (domainRow == null) {
        setState(() {
          _companyDomainError = '등록된 회사/기관 이메일 도메인이 아닙니다.';
          _isResolvingCompany = false;
        });
        return;
      }

      final companyId = (domainRow['company_id'] as String?)?.trim();
      if (companyId == null || companyId.isEmpty) {
        setState(() {
          _companyDomainError = '회사 정보를 확인할 수 없습니다.';
          _isResolvingCompany = false;
        });
        return;
      }

      final companyRow = await client
          .from(CompanyTable().tableName)
          .select('${CompanyRow.idField}, ${CompanyRow.nameField}')
          .eq(CompanyRow.idField, companyId)
          .maybeSingle();

      if (!mounted) return;

      final companyName =
          (companyRow == null ? null : companyRow[CompanyRow.nameField]) as String?;

      setState(() {
        _resolvedCompanyId = companyId;
        _resolvedCompanyName = (companyName ?? '').trim().isEmpty
            ? null
            : companyName!.trim();
        _isResolvingCompany = false;
      });
      _recomputeSubmitEnabled();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _companyDomainError = '회사/기관 정보를 불러오지 못했습니다.';
        _isResolvingCompany = false;
      });
      _recomputeSubmitEnabled();
    }
  }

  bool _isSubmitReady() {
    if (_isSubmitting) return false;
    final email = _emailController.text.trim();
    final pw = _passwordController.text;
    final pw2 = _confirmPasswordController.text;
    final name = _nameController.text.trim();

    if (!_emailRegex.hasMatch(email)) return false;
    if (pw.length < 8) return false;
    if (pw2 != pw) return false;
    if (!_isValidName(name)) return false;

    if (_isCompanySignup) {
      if (_isResolvingCompany) return false;
      if (_resolvedCompanyId == null || _resolvedCompanyId!.isEmpty) return false;
      if (_companyDomainError != null) return false;
    }

    return true;
  }

  void _recomputeSubmitEnabled() {
    final next = _isSubmitReady();
    if (next == _submitEnabled) return;
    if (!mounted) return;
    setState(() => _submitEnabled = next);
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
      company: _isCompanySignup ? _resolvedCompanyId : null,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isCompanySignup && (_resolvedCompanyId == null || _resolvedCompanyId!.isEmpty)) {
      setState(() {
        _companyDomainError ??= '등록된 회사/기관 이메일로 가입해주세요.';
      });
      return;
    }

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
        company: _isCompanySignup ? _resolvedCompanyId : null,
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
    const disabledBg = Color(0xFFE3E3E3);
    const disabledFg = Color(0xFF9A9A9A);

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
                              if (_isCompanySignup) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (_isResolvingCompany) ...[
                                      const SizedBox(
                                        height: 14,
                                        width: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Expanded(
                                      child: Text(
                                        _companyDomainError != null
                                            ? _companyDomainError!
                                            : (_resolvedCompanyName != null
                                                ? '회사/기관: $_resolvedCompanyName'
                                                : '회사/기관이 자동으로 설정됩니다 (이메일 도메인 기준)'),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontFamily: 'Noto Sans KR',
                                          fontWeight: FontWeight.w500,
                                          color: _companyDomainError != null
                                              ? theme.colorScheme.error
                                              : const Color(0xFF666666),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
            onPressed: _submitEnabled ? _handleSubmit : null,
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
