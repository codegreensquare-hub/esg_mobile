import 'package:esg_mobile/core/services/database/mission.row.service.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';
import 'package:esg_mobile/data/models/supabase/tables/mission.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_available.list_tile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MissionParticipationTab extends StatefulWidget {
  const MissionParticipationTab({super.key});

  @override
  State<MissionParticipationTab> createState() =>
      _MissionParticipationTabState();
}

class _MissionParticipationTabState extends State<MissionParticipationTab> {
  late final MissionRowService _missionService;
  late final Future<List<MissionRow>> _missionsFuture;

  @override
  void initState() {
    super.initState();
    _missionService = MissionRowService(Supabase.instance.client);
    _missionsFuture = _missionService.fetchList(
      isPublished: true,
      publicity: MissionPublicity.public,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
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
          child: const Text(
            '오늘 미션참여 가능 횟수 3/3',
            textAlign: TextAlign.center,
          ),
        ),
        FutureBuilder<List<MissionRow>>(
          future: _missionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error loading missions: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No missions available'));
            } else {
              final missions = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: missions.length,
                itemBuilder: (context, index) {
                  final mission = missions[index];
                  return MissionAvailableListTile(
                    mission: mission,
                    onTap: (mission) {
                      // TODO: Handle mission tap, e.g., navigate to participation screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on ${mission.title}')),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
