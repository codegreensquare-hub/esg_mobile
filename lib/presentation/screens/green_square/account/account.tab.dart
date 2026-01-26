import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/push_notification.service.dart';
import 'package:esg_mobile/data/entities/active_mission.dart';
import 'package:esg_mobile/data/entities/stamp.dart';
import 'package:esg_mobile/data/entities/participation.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/account.logged_in_content.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/account.logged_out_content.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/my_comments.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/my_orders.screen.dart';
import 'package:esg_mobile/presentation/screens/auth/signup.screen.dart';
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
  bool _authInProgress = false;
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

  Future<void> _handleLogin(String email, String password) async {
    if (_authInProgress) return;
    setState(() => _authInProgress = true);
    try {
      await UserAuthService.instance.signIn(email, password);
      // Save push notification token on login
      await PushNotificationService.instance.saveTokenOnLogin();
      if (!mounted) return;
      setState(() => isLoading = true);
      await _fetchAccountData();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 중 문제가 발생했습니다. 다시 시도해주세요.')),
      );
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _authInProgress = false);
      }
    }
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
    context.push(SignUpScreen.route);
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

    if (!UserAuthService.instance.isLoggedIn) {
      return AccountLoggedOutContent(
        onLogin: _handleLogin,
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
      companyName: companyName,
      onSelectCompany: _handleSelectCompany,
      onRemoveCompany: _handleRemoveCompany,
      isEmployee: isEmployee,
      departmentName: departmentName,
      onSetIsEmployee: _handleSetIsEmployee,
      onSelectDepartment: _handleSelectDepartment,
      onRemoveDepartment: _handleRemoveDepartment,
    );
  }
}
