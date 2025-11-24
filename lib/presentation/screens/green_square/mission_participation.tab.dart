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
      ],
    );
  }
}
