import 'package:esg_mobile/core/enums/mission_status.dart';
import 'package:esg_mobile/core/services/database/mission.row.service.dart';
import 'package:esg_mobile/core/services/database/mission_participation.service.dart';
import 'package:esg_mobile/core/config/maxParticipation.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_available.list_tile.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_detail.dialog.dart';
import 'package:flutter/material.dart';

class MissionParticipationTab extends StatefulWidget {
  const MissionParticipationTab({
    super.key,
    this.onMissionTap,
    this.onParticipationSuccess,
  });

  final void Function(MissionRow)? onMissionTap;
  final void Function()? onParticipationSuccess;

  @override
  State<MissionParticipationTab> createState() =>
      _MissionParticipationTabState();
}

class _MissionParticipationTabState extends State<MissionParticipationTab> {
  List<MissionRow> currentMissions = [];
  List<MissionRow> pastMissions = [];

  bool showPastMissions = false;
  int todayParticipationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentMissions();
    _fetchPastMissions();
    _fetchTodayParticipationCount();
  }

  void _fetchCurrentMissions() async {
    currentMissions = await MissionService.instance.fetchList(
      isPublished: true,
      status: MissionStatus.current,
      publicity: MissionPublicity.public,
    );
    if (!mounted) return;
    setState(() {});
  }

  void _fetchPastMissions() async {
    pastMissions = await MissionService.instance.fetchList(
      isPublished: true,
      status: MissionStatus.past,
      publicity: MissionPublicity.public,
    );
    if (!mounted) return;
    setState(() {});
  }

  void _fetchTodayParticipationCount() async {
    todayParticipationCount = await MissionParticipationService.instance
        .getTodayParticipationCount();
    if (!mounted) return;
    setState(() {});
  }

  void refreshParticipationCount() {
    _fetchTodayParticipationCount();
    widget.onParticipationSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        SizedBox(height: 48),
        Text('🌿 친환경 미션인증이란? '),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: const Text(
            '일상 속에서 할 수 있는 친환경 활동들을 사진으로 남겨주세요.  환경을 지키면 마일리지로 돌아오는 즐거움,  바로 확인해 보세요! ',
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Text(
            '오늘 미션참여 가능 횟수 $todayParticipationCount/$MAX_PARTICIPATION',
            textAlign: TextAlign.center,
          ),
        ),
        // Current Missions
        if (currentMissions.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '현재 미션',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentMissions.length,
            itemBuilder: (context, index) {
              final mission = currentMissions[index];
              return MissionAvailableListTile(
                mission: mission,
                onTap:
                    widget.onMissionTap ??
                    (mission) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MissionDetailDialog(
                            mission: mission,
                            onParticipationSuccess: refreshParticipationCount,
                          ),
                        ),
                      );
                    },
              );
            },
          ),
        ] else ...[
          const Center(child: Text('현재 진행 중인 미션이 없습니다.')),
        ],
        SizedBox(height: 48),
        // Button to toggle past missions
        ElevatedButton(
          onPressed: () {
            setState(() {
              showPastMissions = !showPastMissions;
            });
          },
          child: Text(showPastMissions ? '- 지난 미션 닫기 -' : '- 지난 미션 보기 -'),
        ),

        // Past Missions
        if (showPastMissions) ...[
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '지난 미션',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (pastMissions.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pastMissions.length,
              itemBuilder: (context, index) {
                final mission = pastMissions[index];
                return MissionAvailableListTile(
                  mission: mission,
                  onTap:
                      widget.onMissionTap ??
                      (mission) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MissionDetailDialog(
                              mission: mission,
                              onParticipationSuccess: refreshParticipationCount,
                            ),
                          ),
                        );
                      },
                );
              },
            ),
          ] else ...[
            const Center(child: Text('지난 미션이 없습니다.')),
          ],
        ],
      ],
    );
  }
}
