import 'package:esg_mobile/core/enums/mission_status.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/mission.row.service.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';
import 'package:esg_mobile/presentation/screens/green_square/account_logged_in_content.dart';
import 'package:esg_mobile/presentation/screens/green_square/account_logged_out_content.dart';
import 'package:esg_mobile/presentation/widgets/green_square/liked_stories_dialog.dart';
import 'package:esg_mobile/presentation/screens/green_square/shipping_addresses.dialog.dart';
import 'package:esg_mobile/presentation/screens/green_square/wishlisted_products.dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  String? userName;
  String? userId;
  int totalMileage = 0;
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
      userName = user.userMetadata?['name'] ?? user.email ?? '사용자';

      final client = Supabase.instance.client;

      // Fetch total mileage (award points from participations)
      final participationResponse = await client
          .from(MissionParticipationTable().tableName)
          .select('mission(award_points)')
          .eq(MissionParticipationRow.participatedByField, user.id);

      totalMileage = participationResponse
          .map(
            (p) =>
                (p['mission'] as Map<String, dynamic>)['award_points'] as int,
          )
          .fold(0, (sum, points) => sum + points);

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
          .select('id, mission(title), created_at')
          .eq(MissionParticipationRow.participatedByField, user.id)
          .order('created_at', ascending: false);

      participations = participationsResponse.map((p) {
        return {
          'id': p['id'],
          'mission_title': (p['mission'] as Map<String, dynamic>)['title'],
          'status': 'approved', // Assume approved for now
          'created_at': p['created_at'],
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원가입 화면으로 이동해 주세요.')),
    );
  }

  void _handleOrderLookup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('주문배송조회 기능은 준비 중입니다.')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('내가 쓴 댓글 기능은 준비 중입니다.')),
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
