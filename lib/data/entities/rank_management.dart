/// Aggregated mission completions for "내가 해낸 미션".
class RankMissionAggregate {
  const RankMissionAggregate({
    required this.missionId,
    required this.title,
    required this.count,
    required this.totalPoints,
  });

  final String missionId;
  final String title;
  final int count;
  final int totalPoints;
}

/// Aggregated stats for the account rank-management UI.
class RankManagementSnapshot {
  const RankManagementSnapshot({
    required this.currentLevel,
    required this.progressToNextLevel,
    required this.approvedMissionCount,
    required this.lifetimeMissionMileage,
    required this.shoppingOrderCount,
    required this.shoppingPurchaseTotalKrw,
    required this.missionsByType,
  });

  final int currentLevel;
  /// 0–1 toward the next tier; 1 when already at max level.
  final double progressToNextLevel;
  final int approvedMissionCount;
  /// Sum of [MissionParticipationRow.awardPoints] for approved rows (matches 등급 혜택 copy).
  final int lifetimeMissionMileage;
  final int shoppingOrderCount;
  final int shoppingPurchaseTotalKrw;
  final List<RankMissionAggregate> missionsByType;
}

/// One row in 적립 / 사용 내역 lists.
class RankMileageHistoryEntry {
  const RankMileageHistoryEntry({
    required this.date,
    required this.title,
    required this.category,
    required this.points,
  });

  final DateTime date;
  final String title;
  final String category;
  final int points;
}
