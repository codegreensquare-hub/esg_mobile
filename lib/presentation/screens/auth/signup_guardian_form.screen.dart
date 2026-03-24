import 'package:esg_mobile/core/navigation/green_square_drawer_navigation.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_form.screen.dart';
import 'package:esg_mobile/presentation/screens/main.screen.dart';
import 'package:esg_mobile/presentation/widgets/layout/green_square_right_drawer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Minor signup sub-flow — Step 2: legal guardian info.
/// After completing this form, the minor's account is created and guardian
/// details are persisted to [public.user_guardian].
class SignupGuardianFormScreen extends StatefulWidget {
  const SignupGuardianFormScreen({super.key, required this.formData});

  static const route = '/signup/guardian';

  final SignupFormData formData;

  @override
  State<SignupGuardianFormScreen> createState() =>
      _SignupGuardianFormScreenState();
}

class _SignupGuardianFormScreenState extends State<SignupGuardianFormScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  DateTime? _selectedBirthdate;
  String? _gender;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  static bool _isValidName(String? s) =>
      s != null && s.trim().length >= 2;

  InputDecoration _fieldDecoration(
    ThemeData theme, {
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide:
            BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final data = widget.formData;
      debugPrint('[SignupGuardianForm] Calling signUp()...');
      final isVerified = await UserAuthService.instance.signUp(
        email: data.email,
        password: data.password,
        username: data.username,
        phone: data.phone,
        birthdate: data.birthdate,
        company: data.company,
      );
      debugPrint('[SignupGuardianForm] signUp() done, isVerified=$isVerified');

      final userId =
          Supabase.instance.client.auth.currentUser?.id;
      debugPrint('[SignupGuardianForm] currentUser?.id=$userId');
      if (userId != null) {
        final guardianBirthdate = _selectedBirthdate != null
            ? _selectedBirthdate!.toIso8601String().split('T')[0]
            : null;
        final guardianRow = UserGuardianRow(
          userId: userId,
          name: _nameController.text.trim(),
          birthdate: guardianBirthdate,
          gender: _gender,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );
        await Supabase.instance.client
            .from(UserGuardianTable().tableName)
            .insert(guardianRow.toJson());
        debugPrint('[SignupGuardianForm] Guardian row inserted');
      }

      if (!mounted) return;
      // After completing the minor + guardian signup flow, always take the
      // user to the main GreenSquare tabbed home screen.
      debugPrint(
        '[SignupGuardianForm] Navigating to main screen after guardian signup',
      );
      context.go(MainScreen.route);
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
                          const SizedBox(height: 8),
                          Text(
                            '법정대리인(보호자) 본인 명의 휴대폰 번호로\n본인확인을 진행해 주세요.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF555555),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
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
                                  _ClearButton(
                                    onPressed: () =>
                                        _nameController.clear(),
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
                                      initialDate: _selectedBirthdate ??
                                          DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedBirthdate = picked;
                                        _birthdateController.text =
                                            '${picked.year.toString().substring(2)}'
                                            '${picked.month.toString().padLeft(2, '0')}'
                                            '${picked.day.toString().padLeft(2, '0')}';
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
                                  _ClearButton(
                                    onPressed: () =>
                                        _phoneController.clear(),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
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
                              if (v == null || v.trim().isEmpty) {
                                return '휴대폰 번호를 입력해주세요.';
                              }
                              return null;
                            },
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

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onPressed});

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
          child: const Icon(Icons.close, size: 12, color: Colors.white),
        ),
      ),
    );
  }
}
