import 'dart:math' as math;

import 'package:esg_mobile/data/entities/rank_management.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// PostgREST reserves the `order` query param for sorting. The `order_item.order`
/// FK must be quoted in filter keys or the server parses `in.(...)` as ORDER BY.
const _orderItemOrderColumnPostgrestFilter = '"order"';

/// Thresholds aligned with account screen "레벨별 혜택" copy (levels 2–5).
class _NextLevelThreshold {
  const _NextLevelThreshold({
    required this.missions,
    required this.mileage,
    required this.orders,
    required this.purchaseKrw,
  });

  final int missions;
  final int mileage;
  final int orders;
  final int purchaseKrw;
}

/// Loads rank stats, mission breakdown, and mileage history for the account dialog.
class RankManagementService {
  RankManagementService._internal({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static final RankManagementService _instance = RankManagementService._internal();

  static RankManagementService get instance => _instance;

  final SupabaseClient _client;

  static const _nextLevelThresholds = <_NextLevelThreshold>[
    _NextLevelThreshold(
      missions: 30,
      mileage: 30000,
      orders: 2,
      purchaseKrw: 30000,
    ),
    _NextLevelThreshold(
      missions: 70,
      mileage: 70000,
      orders: 5,
      purchaseKrw: 100000,
    ),
    _NextLevelThreshold(
      missions: 120,
      mileage: 240000,
      orders: 10,
      purchaseKrw: 450000,
    ),
    _NextLevelThreshold(
      missions: 400,
      mileage: 800000,
      orders: 30,
      purchaseKrw: 800000,
    ),
  ];

  static int computeCurrentLevel({
    required int missionCount,
    required int lifetimeMissionMileage,
    required int orderCount,
    required int purchaseTotalKrw,
  }) {
    if (missionCount >= 400 &&
        lifetimeMissionMileage >= 800000 &&
        orderCount >= 30 &&
        purchaseTotalKrw >= 800000) {
      return 5;
    }
    if (missionCount >= 120 &&
        lifetimeMissionMileage >= 240000 &&
        orderCount >= 10 &&
        purchaseTotalKrw >= 450000) {
      return 4;
    }
    if (missionCount >= 70 &&
        lifetimeMissionMileage >= 70000 &&
        orderCount >= 5 &&
        purchaseTotalKrw >= 100000) {
      return 3;
    }
    if (missionCount >= 30 &&
        lifetimeMissionMileage >= 30000 &&
        orderCount >= 2 &&
        purchaseTotalKrw >= 30000) {
      return 2;
    }
    return 1;
  }

  static double computeProgressToNextLevel({
    required int currentLevel,
    required int missionCount,
    required int lifetimeMissionMileage,
    required int orderCount,
    required int purchaseTotalKrw,
  }) {
    if (currentLevel >= 5) return 1;
    final t = _nextLevelThresholds[currentLevel - 1];
    final rM = missionCount / t.missions;
    final rMi = lifetimeMissionMileage / t.mileage;
    final rO = orderCount / t.orders;
    final rP = purchaseTotalKrw / t.purchaseKrw;
    return math.min(1, math.min(rM, math.min(rMi, math.min(rO, rP))));
  }

  dynamic _applyParticipationProfile(
    dynamic q, {
    required bool isMainProfile,
    required String? selectedProfileId,
  }) {
    if (isMainProfile) {
      return q.isFilter(MissionParticipationRow.profileUsedField, null);
    }
    return q.eq(MissionParticipationRow.profileUsedField, selectedProfileId!);
  }

  dynamic _applyOrderProfile(
    dynamic q, {
    required bool isMainProfile,
    required String? selectedProfileId,
  }) {
    if (isMainProfile) {
      return q.isFilter(OrderRow.profileUsedField, null);
    }
    return q.eq(OrderRow.profileUsedField, selectedProfileId!);
  }

  /// Whether a mileage transaction belongs to the selected account profile context.
  bool _transactionMatchesProfile(
    Map<String, dynamic> row, {
    required bool isMainProfile,
    required String? selectedProfileId,
    required Map<String, String?> participationProfileById,
    required Map<String, String?> orderProfileByTransactionId,
  }) {
    final relatedId = row[AwardPointsTransactionRow.relatedParticipationField]
        as String?;
    final awardAmount =
        (row[AwardPointsTransactionRow.awardAmountField] as num?)?.toDouble() ??
        0;
    final txProfile = row[AwardPointsTransactionRow.profileField] as String?;

    if (relatedId != null && relatedId.isNotEmpty) {
      final p = participationProfileById[relatedId];
      if (isMainProfile) {
        return p == null || p.isEmpty;
      }
      return p == selectedProfileId;
    }

    if (awardAmount < 0) {
      final txId = row[AwardPointsTransactionRow.idField] as String?;
      if (txId == null || txId.isEmpty) return false;
      final orderProfile = orderProfileByTransactionId[txId];
      if (orderProfile != null) {
        if (isMainProfile) {
          return orderProfile.isEmpty;
        }
        return orderProfile == selectedProfileId;
      }
      if (txProfile != null) {
        if (isMainProfile) return false;
        return txProfile == selectedProfileId;
      }
      return isMainProfile;
    }

    if (txProfile != null) {
      if (isMainProfile) return false;
      return txProfile == selectedProfileId;
    }
    return isMainProfile;
  }

  Future<RankManagementSnapshot> fetchSnapshot({
    required String userId,
    required bool isMainProfile,
    required String? selectedProfileId,
  }) async {
    var participationQuery = _client
        .from(MissionParticipationTable().tableName)
        .select(
          '${MissionParticipationRow.missionField},'
          '${MissionParticipationRow.awardPointsField}',
        )
        .eq(MissionParticipationRow.participatedByField, userId)
        .not(MissionParticipationRow.approvedAtField, 'is', null);

    participationQuery = _applyParticipationProfile(
      participationQuery,
      isMainProfile: isMainProfile,
      selectedProfileId: selectedProfileId,
    );

    final participationRows =
        await participationQuery as List<dynamic>? ?? <dynamic>[];

    final missionIds = <String>{};
    var missionCount = 0;
    var lifetimeMileage = 0.0;
    final pointsByMission = <String, double>{};
    final countsByMission = <String, int>{};

    for (final raw in participationRows) {
      final row = raw as Map<String, dynamic>;
      final missionId = row[MissionParticipationRow.missionField] as String?;
      if (missionId == null || missionId.isEmpty) continue;
      missionIds.add(missionId);
      missionCount++;
      final pts =
          (row[MissionParticipationRow.awardPointsField] as num?)?.toDouble() ??
          0;
      lifetimeMileage += pts;
      pointsByMission[missionId] = (pointsByMission[missionId] ?? 0) + pts;
      countsByMission[missionId] = (countsByMission[missionId] ?? 0) + 1;
    }

    final titles = await _fetchMissionTitles(missionIds.toList());

    final aggregates = pointsByMission.entries
        .map(
          (e) => RankMissionAggregate(
            missionId: e.key,
            title: titles[e.key] ?? '미션',
            count: countsByMission[e.key] ?? 0,
            totalPoints: e.value.round(),
          ),
        )
        .toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    var orderQuery = _client
        .from(OrderTable().tableName)
        .select(
          '${OrderRow.idField},'
          '${OrderRow.orderByField},'
          'payment!order_payment_fkey(${PaymentRow.paidAtField})',
        )
        .eq(OrderRow.orderByField, userId);

    orderQuery = _applyOrderProfile(
      orderQuery,
      isMainProfile: isMainProfile,
      selectedProfileId: selectedProfileId,
    );

    final orderRows = await orderQuery as List<dynamic>? ?? <dynamic>[];
    final orderIds = <String>[];

    for (final raw in orderRows) {
      final row = raw as Map<String, dynamic>;
      final paymentData = row['payment'];
      final paidAt = paymentData is Map<String, dynamic>
          ? paymentData['paid_at']
          : null;
      if (paidAt == null) continue;
      final id = row[OrderRow.idField] as String?;
      if (id != null && id.isNotEmpty) orderIds.add(id);
    }

    var purchaseTotal = 0.0;
    if (orderIds.isNotEmpty) {
      final itemRows = await _client
          .from(OrderItemTable().tableName)
          .select(
            '${OrderItemRow.orderField},'
            '${OrderItemRow.priceField},'
            '${OrderItemRow.quantityField},'
            '${OrderItemRow.cancelledAtField}',
          )
          .inFilter(_orderItemOrderColumnPostgrestFilter, orderIds);

      for (final raw in itemRows as List<dynamic>? ?? <dynamic>[]) {
        final row = raw as Map<String, dynamic>;
        if (row[OrderItemRow.cancelledAtField] != null) continue;
        final price =
            (row[OrderItemRow.priceField] as num?)?.toDouble() ?? 0;
        final qty =
            (row[OrderItemRow.quantityField] as num?)?.toDouble() ?? 0;
        purchaseTotal += price * qty;
      }
    }

    final shoppingOrderCount = orderIds.length;
    final lifetimeMissionMileageInt = lifetimeMileage.round();
    final purchaseTotalInt = purchaseTotal.round();

    final level = computeCurrentLevel(
      missionCount: missionCount,
      lifetimeMissionMileage: lifetimeMissionMileageInt,
      orderCount: shoppingOrderCount,
      purchaseTotalKrw: purchaseTotalInt,
    );

    final progress = computeProgressToNextLevel(
      currentLevel: level,
      missionCount: missionCount,
      lifetimeMissionMileage: lifetimeMissionMileageInt,
      orderCount: shoppingOrderCount,
      purchaseTotalKrw: purchaseTotalInt,
    );

    return RankManagementSnapshot(
      currentLevel: level,
      progressToNextLevel: progress,
      approvedMissionCount: missionCount,
      lifetimeMissionMileage: lifetimeMissionMileageInt,
      shoppingOrderCount: shoppingOrderCount,
      shoppingPurchaseTotalKrw: purchaseTotalInt,
      missionsByType: aggregates,
    );
  }

  Future<Map<String, String>> _fetchMissionTitles(List<String> missionIds) async {
    if (missionIds.isEmpty) return {};
    final out = <String, String>{};
    final response = await _client
        .from(MissionTable().tableName)
        .select('${MissionRow.idField},${MissionRow.titleField}')
        .inFilter(MissionRow.idField, missionIds);
    for (final raw in response as List<dynamic>? ?? <dynamic>[]) {
      final row = raw as Map<String, dynamic>;
      final id = row[MissionRow.idField] as String?;
      final title = row[MissionRow.titleField] as String?;
      if (id != null) out[id] = (title?.trim().isNotEmpty ?? false) ? title! : '미션';
    }
    return out;
  }

  Future<Map<String, String?>> _fetchParticipationProfiles(
    Set<String> participationIds,
  ) async {
    if (participationIds.isEmpty) return {};
    final response = await _client
        .from(MissionParticipationTable().tableName)
        .select(
          '${MissionParticipationRow.idField},'
          '${MissionParticipationRow.profileUsedField}',
        )
        .inFilter(MissionParticipationRow.idField, participationIds.toList());
    final out = <String, String?>{};
    for (final raw in response as List<dynamic>? ?? <dynamic>[]) {
      final row = raw as Map<String, dynamic>;
      final id = row[MissionParticipationRow.idField] as String?;
      if (id == null) continue;
      out[id] = row[MissionParticipationRow.profileUsedField] as String?;
    }
    return out;
  }

  Future<Map<String, String?>> _fetchOrderProfileByTransactionId(
    String userId,
    Set<String> transactionIds,
  ) async {
    if (transactionIds.isEmpty) return {};
    final response = await _client
        .from(OrderTable().tableName)
        .select(
          '${OrderRow.transactionReferenceField},'
          '${OrderRow.profileUsedField}',
        )
        .eq(OrderRow.orderByField, userId)
        .inFilter(OrderRow.transactionReferenceField, transactionIds.toList());
    final out = <String, String?>{};
    for (final raw in response as List<dynamic>? ?? <dynamic>[]) {
      final row = raw as Map<String, dynamic>;
      final txRef = row[OrderRow.transactionReferenceField] as String?;
      if (txRef == null || txRef.isEmpty) continue;
      out[txRef] = row[OrderRow.profileUsedField] as String?;
    }
    return out;
  }

  Future<Map<String, String>> _fetchMissionTitlesForParticipations(
    Set<String> participationIds,
  ) async {
    if (participationIds.isEmpty) return {};
    final response = await _client
        .from(MissionParticipationTable().tableName)
        .select(
          '${MissionParticipationRow.idField},'
          '${MissionParticipationRow.missionField}(${MissionRow.titleField})',
        )
        .inFilter(MissionParticipationRow.idField, participationIds.toList());
    final out = <String, String>{};
    for (final raw in response as List<dynamic>? ?? <dynamic>[]) {
      final row = raw as Map<String, dynamic>;
      final id = row[MissionParticipationRow.idField] as String?;
      final missionData = row['mission'] as Map<String, dynamic>?;
      final title = missionData?[MissionRow.titleField] as String?;
      if (id != null) {
        out[id] = (title?.trim().isNotEmpty ?? false) ? title! : '미션';
      }
    }
    return out;
  }

  Future<List<RankMileageHistoryEntry>> fetchEarningHistoryForMonth({
    required String userId,
    required bool isMainProfile,
    required String? selectedProfileId,
    required DateTime month,
  }) async {
    final range = _monthUtcRange(month);
    final txResponse = await _client
        .from(AwardPointsTransactionTable().tableName)
        .select()
        .eq(AwardPointsTransactionRow.awardedUserField, userId)
        .gte(AwardPointsTransactionRow.createdAtField, range.$1.toIso8601String())
        .lt(AwardPointsTransactionRow.createdAtField, range.$2.toIso8601String())
        .gt(AwardPointsTransactionRow.awardAmountField, 0)
        .order(AwardPointsTransactionRow.createdAtField, ascending: false)
        .limit(200);

    final rows = (txResponse as List<dynamic>? ?? <dynamic>[])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final participationIds = rows
        .map((r) => r[AwardPointsTransactionRow.relatedParticipationField] as String?)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    final participationProfiles = await _fetchParticipationProfiles(
      participationIds,
    );
    final titles = await _fetchMissionTitlesForParticipations(participationIds);

    final filtered = <Map<String, dynamic>>[];
    for (final row in rows) {
      if (_transactionMatchesProfile(
        row,
        isMainProfile: isMainProfile,
        selectedProfileId: selectedProfileId,
        participationProfileById: participationProfiles,
        orderProfileByTransactionId: const {},
      )) {
        filtered.add(row);
      }
    }

    return filtered.map((row) {
      final related =
          row[AwardPointsTransactionRow.relatedParticipationField] as String?;
      final title = (related != null && related.isNotEmpty)
          ? (titles[related] ?? '미션 적립')
          : '마일리지 적립';
      final amount =
          (row[AwardPointsTransactionRow.awardAmountField] as num?)?.toDouble() ??
          0;
      final created =
          row[AwardPointsTransactionRow.createdAtField] as String?;
      final date = created != null
          ? DateTime.tryParse(created) ?? DateTime.now()
          : DateTime.now();
      return RankMileageHistoryEntry(
        date: date.toLocal(),
        title: title,
        category: '미션',
        points: amount.round(),
      );
    }).toList();
  }

  Future<List<RankMileageHistoryEntry>> fetchUsedMileageForMonth({
    required String userId,
    required bool isMainProfile,
    required String? selectedProfileId,
    required DateTime month,
  }) async {
    final range = _monthUtcRange(month);
    final txResponse = await _client
        .from(AwardPointsTransactionTable().tableName)
        .select()
        .eq(AwardPointsTransactionRow.awardedUserField, userId)
        .gte(AwardPointsTransactionRow.createdAtField, range.$1.toIso8601String())
        .lt(AwardPointsTransactionRow.createdAtField, range.$2.toIso8601String())
        .lt(AwardPointsTransactionRow.awardAmountField, 0)
        .order(AwardPointsTransactionRow.createdAtField, ascending: false)
        .limit(200);

    final rows = (txResponse as List<dynamic>? ?? <dynamic>[])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final txIds = rows
        .map((r) => r[AwardPointsTransactionRow.idField] as String?)
        .whereType<String>()
        .toSet();

    final orderProfiles = await _fetchOrderProfileByTransactionId(userId, txIds);

    final participationIds = rows
        .map((r) => r[AwardPointsTransactionRow.relatedParticipationField] as String?)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    final participationProfiles = await _fetchParticipationProfiles(
      participationIds,
    );

    final orderIds = await _fetchOrderIdsForTransactions(userId, txIds);

    final productLabels = await _fetchFirstProductLabelPerOrder(orderIds);

    final filtered = <Map<String, dynamic>>[];
    for (final row in rows) {
      if (_transactionMatchesProfile(
        row,
        isMainProfile: isMainProfile,
        selectedProfileId: selectedProfileId,
        participationProfileById: participationProfiles,
        orderProfileByTransactionId: orderProfiles,
      )) {
        filtered.add(row);
      }
    }

    return filtered.map((row) {
      final txId = row[AwardPointsTransactionRow.idField] as String? ?? '';
      final orderId = orderIds[txId];
      final itemTitle =
          (orderId != null && productLabels.containsKey(orderId))
          ? productLabels[orderId]!
          : '쇼핑몰 주문';
      final amount =
          (row[AwardPointsTransactionRow.awardAmountField] as num?)?.toDouble() ??
          0;
      final created =
          row[AwardPointsTransactionRow.createdAtField] as String?;
      final date = created != null
          ? DateTime.tryParse(created) ?? DateTime.now()
          : DateTime.now();
      return RankMileageHistoryEntry(
        date: date.toLocal(),
        title: itemTitle,
        category: '쇼핑몰',
        points: amount.abs().round(),
      );
    }).toList();
  }

  Future<Map<String, String>> _fetchOrderIdsForTransactions(
    String userId,
    Set<String> transactionIds,
  ) async {
    if (transactionIds.isEmpty) return {};
    final response = await _client
        .from(OrderTable().tableName)
        .select(
          '${OrderRow.idField},'
          '${OrderRow.transactionReferenceField}',
        )
        .eq(OrderRow.orderByField, userId)
        .inFilter(OrderRow.transactionReferenceField, transactionIds.toList());
    final out = <String, String>{};
    for (final raw in response as List<dynamic>? ?? <dynamic>[]) {
      final row = raw as Map<String, dynamic>;
      final txRef = row[OrderRow.transactionReferenceField] as String?;
      final id = row[OrderRow.idField] as String?;
      if (txRef != null && id != null) out[txRef] = id;
    }
    return out;
  }

  Future<Map<String, String>> _fetchFirstProductLabelPerOrder(
    Map<String, String> transactionToOrderId,
  ) async {
    final orderIds = transactionToOrderId.values.toSet().toList();
    if (orderIds.isEmpty) return {};
    final response = await _client
        .from(OrderItemTable().tableName)
        .select(
          '${OrderItemRow.orderField},'
          'product(${ProductRow.titleField},${ProductRow.nameField})',
        )
        .inFilter(_orderItemOrderColumnPostgrestFilter, orderIds);
    final byOrder = <String, String>{};
    for (final raw in response as List<dynamic>? ?? <dynamic>[]) {
      final row = raw as Map<String, dynamic>;
      final orderId = row[OrderItemRow.orderField] as String?;
      if (orderId == null || byOrder.containsKey(orderId)) continue;
      final productData = row['product'] as Map<String, dynamic>?;
      final title = productData?[ProductRow.titleField] as String?;
      final name = productData?[ProductRow.nameField] as String?;
      final label = (title?.trim().isNotEmpty ?? false)
          ? title!.trim()
          : (name?.trim().isNotEmpty ?? false)
          ? name!.trim()
          : '상품';
      byOrder[orderId] = label;
    }
    return byOrder;
  }

  /// Inclusive start, exclusive end in UTC.
  (DateTime, DateTime) _monthUtcRange(DateTime month) {
    final y = month.year;
    final m = month.month;
    final start = DateTime.utc(y, m, 1);
    final end = m == 12 ? DateTime.utc(y + 1, 1, 1) : DateTime.utc(y, m + 1, 1);
    return (start, end);
  }

  int sumPoints(List<RankMileageHistoryEntry> entries) =>
      entries.fold<int>(0, (s, e) => s + e.points);
}
