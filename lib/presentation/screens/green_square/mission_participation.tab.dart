import 'package:esg_mobile/data/models/supabase/tables/mission.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_available.list_tile.dart';
import 'package:flutter/material.dart';

class MissionParticipationTab extends StatelessWidget {
  const MissionParticipationTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // TODO update UI
    return Column(
      children: [
        Text('🌿 친환경 미션인증이란? '),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: Text(
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
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: Text(
            '오늘 미션참여 가능 횟수 3/3',
            textAlign: TextAlign.center,
          ),
        ),
        Column(
          children: [
            MissionAvailableListTile(
              mission: MissionRow(
                id: 'test',
                title: '플라스틱 줄이기',
                text: '일회용 플라스틱 사용을 줄이고, 재사용 가능한 물품을 사용해요.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
