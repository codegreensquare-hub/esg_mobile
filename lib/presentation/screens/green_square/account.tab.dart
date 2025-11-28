import 'package:esg_mobile/core/enums/mission_status.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/mission.row.service.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';
import 'package:esg_mobile/presentation/widgets/green_square/liked_stories_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  String? userName;
  int totalMileage = 0;
  List<Map<String, dynamic>> activeMissions = [];
  List<Map<String, dynamic>> participations = [];
  bool isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            userName ?? '사용자',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Level
          Text(
            'Level 1',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Manage shipping address button
          OutlinedButton(
            onPressed: () {
              // TODO: Navigate to shipping address management
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('배송지 관리 기능은 준비 중입니다.')),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('배송지 관리'),
          ),
          const SizedBox(height: 24),
          // Current mileage
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '현재 보유 마일리지',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '$totalMileage P',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.local_shipping_outlined,
                  label: '주문배송조회',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('주문배송조회 기능은 준비 중입니다.')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.favorite_outline,
                  label: '찜한 상품',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('찜한 상품 기능은 준비 중입니다.')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.comment_outlined,
                  label: '내가 쓴 댓글',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('내가 쓴 댓글 기능은 준비 중입니다.')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.thumb_up_outlined,
                  label: '좋아요 한 글',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => const LikedStoriesDialog(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Active Missions grid
          Text(
            '현재 미션',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (activeMissions.isEmpty)
            const Center(child: Text('현재 진행 중인 미션이 없습니다.'))
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: activeMissions.map((mission) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission['title'] ?? '미션',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        '+${mission['earned']} P',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 32),
          // Participations list
          Text(
            '참여 기록',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (participations.isEmpty)
            const Center(child: Text('참여 기록이 없습니다.'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participations.length,
              itemBuilder: (context, index) {
                final participation = participations[index];
                final status = participation['status'] as String;
                final isApproved = status == 'approved';
                final isPending = status == 'pending';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              participation['mission_title'] ?? '미션',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '참여일: ${DateTime.parse(participation['created_at']).toLocal().toString().split(' ')[0]}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? Colors.green.shade100
                              : isPending
                              ? Colors.orange.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isApproved
                              ? '승인됨'
                              : isPending
                              ? '심사 중'
                              : '거부됨',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isApproved
                                ? Colors.green.shade800
                                : isPending
                                ? Colors.orange.shade800
                                : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
