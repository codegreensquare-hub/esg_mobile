import 'stamp.dart';

class ActiveMission {
  const ActiveMission({
    required this.id,
    required this.title,
    required this.awardPoints,
    required this.earned,
    this.stamp,
  });

  final String id;
  final String? title;
  final int? awardPoints;
  final int earned;
  final Stamp? stamp;

  factory ActiveMission.fromJson(Map<String, dynamic> json) {
    return ActiveMission(
      id: json['id'] as String,
      title: json['title'] as String?,
      awardPoints: json['award_points'] as int?,
      earned: json['earned'] as int,
      stamp: json['stamp'] != null ? Stamp.fromJson(json['stamp']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'award_points': awardPoints,
      'earned': earned,
      'stamp': stamp?.toJson(),
    };
  }

  String? get stampUrl => stamp?.url;
}
