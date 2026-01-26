import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/constants/asset.dart' as asset_constants;
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/presentation/widgets/green_square/underline_value.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GreenSquareStatisticsBanner extends StatefulWidget {
  const GreenSquareStatisticsBanner({super.key});

  @override
  State<GreenSquareStatisticsBanner> createState() =>
      _GreenSquareStatisticsBannerState();
}

class _GreenSquareStatisticsBannerState
    extends State<GreenSquareStatisticsBanner> {
  List<Map<String, dynamic>> topMissions = [];
  int totalApprovedParticipations = 0;
  double totalAwardPoints = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchTopMissions(),
      _fetchTotalApprovedParticipations(),
      _fetchTotalAwardPoints(),
    ]);
  }

  Future<void> _fetchTopMissions() async {
    try {
      final result = await Supabase.instance.client.rpc(
        'get_top_missions_by_approved_participations',
      );
      if (mounted) {
        setState(() => topMissions = List<Map<String, dynamic>>.from(result));
      }
    } catch (e) {
      debugPrint('Error fetching top missions: $e');
    }
  }

  Future<void> _fetchTotalApprovedParticipations() async {
    try {
      final result = await Supabase.instance.client.rpc(
        'get_total_approved_participations',
      );
      if (mounted) {
        setState(() => totalApprovedParticipations = result as int);
      }
    } catch (e) {
      debugPrint('Error fetching total approved participations: $e');
    }
  }

  Future<void> _fetchTotalAwardPoints() async {
    try {
      final result = await Supabase.instance.client.rpc(
        'get_total_award_points_from_approved_participations',
      );
      if (mounted) {
        setState(() => totalAwardPoints = (result as num).toDouble());
      }
    } catch (e) {
      debugPrint('Error fetching total award points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
        minHeight: 200,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            getImageLink(
              bucket.asset,
              asset_constants.asset.trees,
              folderPath:
                  asset_constants.assetFolderPath[asset_constants.asset.trees],
            ),
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
        ),
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '🌳 마일리지로 응원한 친환경 소비',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: ShapeDecoration(
                  shape: OvalBorder(
                    side: const BorderSide(color: Colors.white, width: 0.8),
                  ),
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Text(
                  '${NumberFormat.decimalPattern().format(totalAwardPoints.toInt())}원',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 42),
            Text(
              '그리더들이 함께한 친환경 인증',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: ShapeDecoration(
                  shape: OvalBorder(
                    side: const BorderSide(color: Colors.white, width: 0.8),
                  ),
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Text(
                  '${NumberFormat.decimalPattern().format(totalApprovedParticipations)}회',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (topMissions.isNotEmpty)
                      UnderlineValue(
                        title: topMissions[0]['title'] as String? ?? '미션',
                        value: topMissions[0]['approved_count'] as int? ?? 0,
                      ),
                    if (topMissions.length > 1)
                      UnderlineValue(
                        title: topMissions[1]['title'] as String? ?? '미션',
                        value: topMissions[1]['approved_count'] as int? ?? 0,
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (topMissions.length > 2)
                      UnderlineValue(
                        title: topMissions[2]['title'] as String? ?? '미션',
                        value: topMissions[2]['approved_count'] as int? ?? 0,
                      ),
                    if (topMissions.length > 3)
                      UnderlineValue(
                        title: topMissions[3]['title'] as String? ?? '미션',
                        value: topMissions[3]['approved_count'] as int? ?? 0,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
