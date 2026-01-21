class ActiveMission {
  const ActiveMission({
    required this.id,
    required this.title,
    required this.awardPoints,
    required this.earned,
  });

  final String id;
  final String? title;
  final int? awardPoints;
  final int earned;

  factory ActiveMission.fromJson(Map<String, dynamic> json) {
    return ActiveMission(
      id: json['id'] as String,
      title: json['title'] as String?,
      awardPoints: json['award_points'] as int?,
      earned: json['earned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'award_points': awardPoints,
      'earned': earned,
    };
  }
}
