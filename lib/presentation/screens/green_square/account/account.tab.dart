import 'package:esg_mobile/core/enums/device.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/data/entities/active_mission.dart';
import 'package:esg_mobile/data/entities/stamp.dart';
import 'package:esg_mobile/data/entities/participation.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/account.logged_in_content.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/profile_select.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/account.logged_out_content.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/blocked_report_history.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/my_comments.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/my_orders.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/login.dialog.dart';
import 'package:esg_mobile/presentation/screens/auth/signup_type.screen.dart';
import 'package:esg_mobile/presentation/widgets/green_square/liked_stories_dialog.dart';
import 'package:esg_mobile/presentation/screens/green_square/shipping_addresses.dialog.dart';
import 'package:esg_mobile/presentation/screens/green_square/wishlisted_products.dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  String? userName;
  String? userId;
  double totalMileage = 0;
  List<ActiveMission> activeMissions = [];
  List<Participation> participations = [];
  bool isLoading = true;
  String? companyName;
  bool? isEmployee;
  String? departmentName;

  @override
  void initState() {
    super.initState();
    _fetchAccountData();
  }

  Future<void> _fetchAccountData() async {
    try {
      final user = UserAuthService.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      userId = user.id;
      userName = UserAuthService.instance.displayName;

      final client = Supabase.instance.client;

      // Fetch user company, is_employee, department
      final userRow = await client
          .from('user')
          .select('company, is_employee, department')
          .eq('id', user.id)
          .single();
      final companyId = userRow['company'] as String?;
      isEmployee = userRow['is_employee'] as bool?;
      final departmentId = userRow['department'] as String?;
      if (companyId != null) {
        final companyRow = await client
            .from('company')
            .select('name')
            .eq('id', companyId)
            .single();
        companyName = companyRow['name'] as String?;
      } else {
        companyName = null;
      }
      if (departmentId != null) {
        final departmentRow = await client
            .from('department')
            .select('name')
            .eq('id', departmentId)
            .single();
        departmentName = departmentRow['name'] as String?;
      } else {
        departmentName = null;
      }

      // Fetch total mileage from award_points balance
      final pointsRow = await client
          .from(AwardPointsTable().tableName)
          .select(AwardPointsRow.pointsField)
          .eq(AwardPointsRow.userField, user.id)
          .maybeSingle();

      totalMileage =
          (pointsRow?[AwardPointsRow.pointsField] as num?)?.toDouble() ?? 0;

      // Fetch all active missions
      final now = DateTime.now().toIso8601String().split('T')[0];
      final missionResponse = await client
          .from('mission')
          .select(
            'id, title, award_points, stamp(bucket, folder_path, file_name)',
          )
          .eq('is_published', true)
          .eq('publicity', 'public')
          .lte('start_active_date', now)
          .gte('last_active_date', now)
          .order('order');

      final missionIds = missionResponse.map((m) => m['id'] as String).toList();

      // Fetch earned points for all missions in one query
      final earnedResponse = missionIds.isNotEmpty
          ? await client
                .from('mission_participation')
                .select('id, award_points, mission')
                .eq('participated_by', user.id)
                .filter('mission', 'in', missionIds)
          : [];

      final earnedMap = <String, int>{};
      for (final row in earnedResponse) {
        final mid = row['mission'] as String?;
        final points = (row?['award_points'] ?? 0) as int;
        if (mid != null) {
          earnedMap[mid] = (earnedMap[mid] ?? 0) + points;
        }
      }

      // Build active missions
      final List<ActiveMission> missionsWithPoints = [];
      for (final missionData in missionResponse) {
        final missionId = missionData['id'] as String;
        final title = missionData['title'] as String?;
        final awardPoints = missionData['award_points'] as int?;
        final earned = earnedMap[missionId] ?? 0;

        final stampData = missionData['stamp'] as Map<String, dynamic>?;
        final stamp = stampData != null ? Stamp.fromJson(stampData) : null;

        missionsWithPoints.add(
          ActiveMission(
            id: missionId,
            title: title,
            awardPoints: awardPoints,
            earned: earned,
            stamp: stamp,
          ),
        );
      }

      activeMissions = missionsWithPoints;

      // Fetch user's participations with mission details
      final participationsResponse = await client
          .from(MissionParticipationTable().tableName)
          .select(
            'id, mission(title, stamp(bucket, folder_path, file_name)), created_at, approved_at, rejected_at, rejected_by, rejection_reason, photo_bucket, photo_folder_path, photo_file_name',
          )
          .eq(MissionParticipationRow.participatedByField, user.id)
          .order('created_at', ascending: false);

      participations = participationsResponse.map((p) {
        final approvedAt = p['approved_at'];
        final rejectedBy = p['rejected_by'];
        final rejectionReason = p['rejection_reason'] as String?;
        final status = approvedAt != null
            ? 'approved'
            : (rejectedBy != null || rejectionReason != null)
            ? 'rejected'
            : 'pending';
        final bucket = p['photo_bucket'] as String?;
        final folder = p['photo_folder_path'] as String?;
        final fileName = p['photo_file_name'] as String?;
        String? photoUrl;
        if (bucket != null && fileName != null) {
          final path = folder != null && folder.isNotEmpty
              ? '$folder/$fileName'
              : fileName;
          photoUrl = Supabase.instance.client.storage
              .from(bucket)
              .getPublicUrl(path);
        }
        final missionData = p['mission'] as Map<String, dynamic>?;
        String? stampUrl;
        if (missionData != null) {
          final stampData = missionData['stamp'] as Map<String, dynamic>?;
          if (stampData != null) {
            final bucket = stampData['bucket'] as String?;
            final folder = stampData['folder_path'] as String?;
            final fileName = stampData['file_name'] as String?;
            if (bucket != null && fileName != null) {
              final path = folder != null && folder.isNotEmpty
                  ? '$folder/$fileName'
                  : fileName;
              stampUrl = Supabase.instance.client.storage
                  .from(bucket)
                  .getPublicUrl(path);
            }
          }
        }
        return Participation(
          id: p['id'] as String,
          missionTitle: missionData?['title'] as String? ?? '미션',
          status: status,
          createdAt: DateTime.parse(p['created_at'] as String),
          photoUrl: photoUrl,
          rejectionReason: rejectionReason,
          stampUrl: stampUrl,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching account data: $e');
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void _openShippingAddressDialog() {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ShippingAddressesDialog(
          userId: userId!,
        ),
      ),
    );
  }

  void _handleSignupTap() {
    context.push(SignupTypeScreen.route);
  }

  Future<void> _handleEmailLogin() async {
    final result = await showDialog<LoginDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoginDialog(),
    );
    if (result == true && mounted) {
      await _fetchAccountData();
    }
  }

  void _handleKakaoLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('카카오 로그인은 준비 중입니다.')),
    );
  }

  void _handleAppleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple 로그인은 준비 중입니다.')),
    );
  }

  void _handleOrderLookup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyOrdersScreen(),
      ),
    );
  }

  void _openWishlist() {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => WishlistedProductsDialog(
          userId: userId!,
        ),
      ),
    );
  }

  void _handleMyComments() {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyCommentsScreen(userId: userId!),
      ),
    );
  }

  void _openLikedStories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const LikedStoriesDialog(),
      ),
    );
  }

  void _handleBlockedReportHistory() {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            BlockedReportHistoryScreen(userId: userId!),
      ),
    );
  }

  void _handleSelectCompany() {
    // TODO: implement company selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회사 선택 기능이 곧 추가됩니다.')),
    );
  }

  Future<void> _handleRemoveCompany() async {
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('user')
          .update({'company': null})
          .eq('id', userId!);
      setState(() => companyName = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회사가 제거되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회사 제거 중 오류가 발생했습니다.')),
      );
    }
  }

  void _handleSetIsEmployee(bool value) async {
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('user')
          .update({'is_employee': value})
          .eq('id', userId!);
      setState(() => isEmployee = value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관계가 업데이트되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

  void _handleSelectDepartment() {
    // TODO: implement department selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('부서 선택 기능이 곧 추가됩니다.')),
    );
  }

  void _handleViewBenefitsByLevel() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final maxWidth = Device.largeMobile.breakpoint;
        final maxHeight = MediaQuery.of(context).size.height * 0.5;
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '등급별 혜택',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Noto Sans KR',
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _BenefitsByLevelContent(colorScheme: cs, textTheme: theme.textTheme),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRemoveDepartment() async {
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('user')
          .update({'department': null})
          .eq('id', userId!);
      setState(() => departmentName = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('부서가 제거되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('부서 제거 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (isLoading) {
      return SizedBox(
        height: screenHeight - 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return ListenableBuilder(
      listenable: UserAuthService.instance,
      builder: (context, _) {
        if (!UserAuthService.instance.isLoggedIn) {
          return AccountLoggedOutContent(
            onKakaoLogin: _handleKakaoLogin,
            onAppleLogin: _handleAppleLogin,
            onEmailLogin: _handleEmailLogin,
            onSignupTap: _handleSignupTap,
          );
        }

        return AccountLoggedInContent(
          userName: userName ?? '사용자',
          totalMileage: totalMileage,
          activeMissions: activeMissions,
          participations: participations,
          onManageShipping: _openShippingAddressDialog,
          onOrderLookup: _handleOrderLookup,
          onWishlist: _openWishlist,
          onMyComments: _handleMyComments,
          onLikedStories: _openLikedStories,
          onBlockedReportHistory: _handleBlockedReportHistory,
          companyName: companyName,
          onSelectCompany: _handleSelectCompany,
          onRemoveCompany: _handleRemoveCompany,
          isEmployee: isEmployee,
          departmentName: departmentName,
          onSetIsEmployee: _handleSetIsEmployee,
          onSelectDepartment: _handleSelectDepartment,
          onRemoveDepartment: _handleRemoveDepartment,
          onViewBenefitsByLevel: _handleViewBenefitsByLevel,
          onProfileChange: _handleProfileChange,
        );
      },
    );
  }

  void _handleProfileChange() {
    context.push(ProfileSelectScreen.route);
  }
}

class _BenefitsByLevelContent extends StatelessWidget {
  const _BenefitsByLevelContent({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // General info box (light green, square, one line)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0x4D339C87), // #339C87 at 30% opacity
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '• 등급 적용 기간 : 매월 1일 ~ 매월 말일',
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF355148),
                  fontFamily: 'Noto Sans KR',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• 등급 산정 기간 : 직전 6개월',
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF355148),
                  fontFamily: 'Noto Sans KR',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _LevelSection(
          level: 1,
          conditions: const ['[그린스퀘어] 서비스 가입 시 자동 충족'],
          benefits: const ['쇼핑몰 1,000원 할인 쿠폰 1매'],
          textTheme: textTheme,
        ),
        _LevelSection(
          level: 2,
          conditions: const [
            '누적 미션 수행 횟수 30회 이상',
            '누적 적립 마일리지 30,000 이상',
            '쇼핑몰 이용 횟수 2회 이상',
            '쇼핑몰 누적 구매 금액 30,000원 이상',
          ],
          benefits: const ['쇼핑몰 2,000원 할인 쿠폰 1매'],
          textTheme: textTheme,
        ),
        _LevelSection(
          level: 3,
          conditions: const [
            '누적 미션 수행 횟수 70회 이상',
            '누적 적립 마일리지 70,000 이상',
            '쇼핑몰 이용 횟수 5회 이상',
            '쇼핑몰 누적 구매 금액 100,000원 이상',
          ],
          benefits: const [
            '미션 당 20마일리지 추가 적립',
            '쇼핑몰 4,000원 할인 쿠폰 2매 (중복 사용 불가)',
          ],
          textTheme: textTheme,
        ),
        _LevelSection(
          level: 4,
          conditions: const [
            '누적 미션 수행 횟수 120회 이상',
            '누적 적립 마일리지 240,000 이상',
            '쇼핑몰 이용 횟수 10회 이상',
            '쇼핑몰 누적 구매 금액 450,000원 이상',
          ],
          benefits: const [
            '미션 당 30마일리지 추가 적립',
            '쇼핑몰 5,000원 할인 쿠폰 6매 (중복 사용 불가)',
          ],
          textTheme: textTheme,
        ),
        _LevelSection(
          level: 5,
          conditions: const [
            '누적 미션 수행 횟수 400회 이상',
            '누적 적립 마일리지 800,000 이상',
            '쇼핑몰 이용 횟수 30회 이상',
            '쇼핑몰 누적 구매 금액 800,000원 이상',
          ],
          benefits: const [
            '미션 당 100마일리지 추가 적립',
            '쇼핑몰 10,000원 할인 쿠폰 6매 (중복 사용 불가)',
            '쇼핑몰 무료배송 쿠폰 3매 (할인 쿠폰과 중복 사용 가능)',
          ],
          textTheme: textTheme,
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  '유의사항',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Noto Sans KR',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• 쇼핑몰은 하나의 주문번호가 1회 이용으로 측정됩니다.\n'
                '• 모든 등급별 혜택(쇼핑몰 쿠폰 포함)은 해당 등급 적용 기간 내에만 사용 가능합니다.\n'
                '• 일정 기간 내 반복적인 쇼핑몰 구매 취소 또는 미션 참여 어뷰징이 적발될 경우, 내부 정책에 따라 등급 조정 및 혜택 제공이 제한될 수 있습니다.',
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF938F8B),
                  fontFamily: 'Noto Sans KR',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({
    required this.level,
    required this.conditions,
    required this.benefits,
    required this.textTheme,
  });

  static const _bulletColor = Color(0xFF938F8B);

  final int level;
  final List<String> conditions;
  final List<String> benefits;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bulletStyle = textTheme.bodySmall?.copyWith(
      color: _bulletColor,
      fontFamily: 'Noto Sans KR',
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level $level',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'EB Garamond',
              decoration: TextDecoration.underline,
              decorationColor: textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '충족 조건',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'Noto Sans KR',
            ),
          ),
          const SizedBox(height: 4),
          ...conditions.map((c) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Text('• $c', style: bulletStyle),
          )),
          const SizedBox(height: 8),
          Text(
            '혜택',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'Noto Sans KR',
            ),
          ),
          const SizedBox(height: 4),
          ...benefits.map((b) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Text('• $b', style: bulletStyle),
          )),
        ],
      ),
    );
  }
}
