import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class MissionWithStampWithParticipations {
  final MissionRow mission;
  final StampRow? stamp;
  final List<MissionParticipationRow> participations;

  MissionWithStampWithParticipations({
    required this.mission,
    this.stamp,
    this.participations = const [],
  });

  factory MissionWithStampWithParticipations.fromJson(
    Map<String, dynamic> json,
  ) {
    return MissionWithStampWithParticipations(
      mission: MissionRow.fromJson(json['mission'] as Map<String, dynamic>),
      stamp: json['stamp'] != null
          ? StampRow.fromJson(json['stamp'] as Map<String, dynamic>)
          : null,
      participations: (json['participations'] as List<dynamic>)
          .map(
            (e) => MissionParticipationRow.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
