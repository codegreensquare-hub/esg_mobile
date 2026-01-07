import 'package:esg_mobile/core/constants/frame_width.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/user_shipping_address.service.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/green_square/my_orders.screen.dart';
import 'package:flutter/material.dart';

class CodeGreenLoginTab extends StatefulWidget {
  const CodeGreenLoginTab({super.key});

  @override
  State<CodeGreenLoginTab> createState() => _CodeGreenLoginTabState();
}

class _CodeGreenLoginTabState extends State<CodeGreenLoginTab> {
  bool _isSubmitting = false;
  Future<UserShippingAddressRow?>? _defaultAddressFuture;

  @override
  void initState() {
    super.initState();
    _refreshDefaultAddress();
  }

  Future<void> _refreshDefaultAddress() async {
    final userId = UserAuthService.instance.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      if (!mounted) {
        _defaultAddressFuture = null;
        return;
      }
      setState(() => _defaultAddressFuture = null);
      return;
    }

    final future = () async {
      final service = UserShippingAddressService.instance;
      final defaultId = await service.fetchDefaultAddressId(userId);
      if (defaultId == null || defaultId.trim().isEmpty) {
        return null;
      }
      return service.fetchAddressById(userId: userId, addressId: defaultId);
    }();

    if (!mounted) {
      _defaultAddressFuture = future;
      return;
    }
    setState(() => _defaultAddressFuture = future);
  }

  Future<void> _loginWithKakao() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await UserAuthService.instance.signInWithKakao();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오 로그인에 실패했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    await _refreshDefaultAddress();
  }

  Future<void> _logout() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await UserAuthService.instance.signOut();
      await _refreshDefaultAddress();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃에 실패했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _openGuestOrderInquiry() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
    );
  }

  Future<void> _openOrders() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedBuilder(
      animation: UserAuthService.instance,
      builder: (context, _) {
        final auth = UserAuthService.instance;
        final user = auth.currentUser;
        final isLoggedIn = user != null;

        if (isLoggedIn) {
          final displayName = auth.displayName;
          final email = (user.email ?? '').trim();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: frameWidth),
                    child: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            '내 정보',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (email.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      email,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '기본 배송지',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  FutureBuilder<UserShippingAddressRow?>(
                                    future: _defaultAddressFuture,
                                    builder: (context, snapshot) {
                                      final address = snapshot.data;
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Align(
                                          alignment: Alignment.centerLeft,
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      }

                                      if (address == null) {
                                        return Text(
                                          '기본 배송지가 설정되어 있지 않습니다.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                              ),
                                        );
                                      }

                                      final title = (address.name ?? '').trim();
                                      final line1 = (address.address ?? '')
                                          .trim();
                                      final line2 =
                                          (address.detailedAddress ?? '')
                                              .trim();
                                      final recipient =
                                          (address.recipientName ?? '').trim();
                                      final phone = (address.phoneNumber ?? '')
                                          .trim();

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (title.isNotEmpty)
                                            Text(
                                              title,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          if (recipient.isNotEmpty ||
                                              phone.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              [
                                                if (recipient.isNotEmpty)
                                                  recipient,
                                                if (phone.isNotEmpty) phone,
                                              ].join(' · '),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: cs.onSurfaceVariant,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                          if (line1.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(line1),
                                          ],
                                          if (line2.isNotEmpty) Text(line2),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _isSubmitting ? null : _openOrders,
                              child: const Text('주문 내역'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _isSubmitting ? null : _logout,
                              child: Text(
                                _isSubmitting ? '처리 중...' : '로그아웃',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: frameWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          '로그인',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '코드그린의 그리더가 되세요',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '신규회원 로그인 시, 10% 쿠폰 증정',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              // Full-width promo box (edge-to-edge)
              Container(
                width: double.infinity,
                height: 160,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/login/login2.0e2030c6.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  child: Text(
                    'CODE GREEN 상품 첫 구매시,\n10% 할인 쿠폰 증정',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: frameWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _loginWithKakao,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFEE500),
                              foregroundColor: Colors.black,
                              shape: const StadiumBorder(),
                              textStyle: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(
                              _isSubmitting ? '로그인 중...' : '카카오 계정으로 로그인',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _openGuestOrderInquiry,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              textStyle: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('비회원 주문확인'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
