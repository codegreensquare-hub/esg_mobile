import 'package:esg_mobile/core/enums/mission_status.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/mission.row.service.dart';
import 'package:esg_mobile/core/services/push_notification.service.dart';
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
  List<Map<String, dynamic>> activeMissions = [];
  List<Map<String, dynamic>> participations = [];
  bool isLoading = true;
  bool _authInProgress = false;

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

      // Fetch total mileage from award_points balance
      final pointsRow = await client
          .from(AwardPointsTable().tableName)
          .select(AwardPointsRow.pointsField)
          .eq(AwardPointsRow.userField, user.id)
          .maybeSingle();

      totalMileage =
          (pointsRow?[AwardPointsRow.pointsField] as num?)?.toDouble() ?? 0;

      // Fetch all active missions
      final missionList = await MissionService.instance.fetchList(
        isPublished: true,
        status: MissionStatus.current,
        publicity: MissionPublicity.public,
      );

      // For each mission, calculate earned points
      final List<Map<String, dynamic>> missionsWithPoints = [];
      for (final mission in missionList) {
        final missionId = mission.id;
        final sumResponse = await client
            .from(MissionParticipationTable().tableName)
            .select('mission(award_points)')
            .eq(MissionParticipationRow.participatedByField, user.id)
            .eq(MissionParticipationRow.missionField, missionId);

        final earned = sumResponse
            .map(
              (p) =>
                  (p['mission'] as Map<String, dynamic>)['award_points'] as int,
            )
            .fold(0, (sum, points) => sum + points);

        missionsWithPoints.add({
          'id': missionId,
          'title': mission.title,
          'award_points': mission.awardPoints,
          'earned': earned,
        });
      }

      activeMissions = missionsWithPoints;

      // Fetch user's participations with mission details
      final participationsResponse = await client
          .from(MissionParticipationTable().tableName)
          .select(
            'id, mission(title), created_at, approved_at, rejected_at, rejected_by, rejection_reason, photo_bucket, photo_folder_path, photo_file_name',
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
        return {
          'id': p['id'],
          'mission_title': missionData != null ? missionData['title'] : '미션',
          'status': status,
          'created_at': p['created_at'],
          'photo_url': photoUrl,
          'rejection_reason': rejectionReason,
        };
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
    );
  }
}
