import 'package:supabase/supabase.dart';

import 'package:esg_mobile/core/enums/mission_status.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';

typedef _FilterStep =
    PostgrestFilterBuilder Function(
      PostgrestFilterBuilder builder,
    );

/// Lightweight wrapper around the generated [MissionTable] that exposes
/// typed CRUD helpers plus common listing queries.
class MissionRowService {
  MissionRowService(
    this._client, {
    MissionTable? missionTable,
  }) : _missionTable = missionTable ?? MissionTable();

  final SupabaseClient _client;
  final MissionTable _missionTable;

  PostgrestQueryBuilder get _baseQuery => _client.from(_missionTable.tableName);

  /// Inserts a new mission row and returns the created record.
  Future<MissionRow> create(MissionRow row) async {
    final response = await _baseQuery.insert(row.toJson()).select().single();
    return MissionRow.fromJson(response);
  }

  /// Retrieves a mission by its primary key. Returns null if not found.
  Future<MissionRow?> fetchById(String id) async {
    final data = await _baseQuery
        .select()
        .eq(MissionRow.idField, id)
        .maybeSingle();
    return data == null ? null : MissionRow.fromJson(data);
  }

  /// Lists missions with optional filters and ordering.
  Future<List<MissionRow>> fetchList({
    MissionType? type,
    MissionPublicity? publicity,
    bool? isPublished,
    DateTime? lastActiveDateBefore,
    DateTime? lastActiveDateAfter,
    MissionStatus? status,
    int? limit,
    int? offset,
    String orderBy = MissionRow.orderField,
    bool ascending = true,
  }) async {
    final now = DateTime.now().toIso8601String().split('T')[0];
    final filters = <_FilterStep>[
      if (type != null)
        (builder) => builder.eq(MissionRow.typeField, type.name),
      if (publicity != null)
        (builder) => builder.eq(MissionRow.publicityField, publicity.name),
      if (isPublished != null)
        (builder) => builder.eq(MissionRow.isPublishedField, isPublished),
      if (lastActiveDateBefore != null)
        (builder) => builder.lt(
          MissionRow.lastActiveDateField,
          lastActiveDateBefore.toIso8601String().split('T')[0],
        ),
      if (lastActiveDateAfter != null)
        (builder) => builder.gte(
          MissionRow.lastActiveDateField,
          lastActiveDateAfter.toIso8601String().split('T')[0],
        ),
      if (status == MissionStatus.current)
        (builder) => builder
            .lte(MissionRow.startActiveDateField, now)
            .gte(MissionRow.lastActiveDateField, now),
      if (status == MissionStatus.past)
        (builder) => builder.lt(MissionRow.lastActiveDateField, now),
    ];
    print('Filters applied: $filters');

    final filtered = filters.fold<PostgrestFilterBuilder>(
      _baseQuery.select(),
      (builder, apply) => apply(builder),
    );

    final ordered = filtered.order(orderBy, ascending: ascending);

    final result = switch ((limit, offset)) {
      (int l, int o) => ordered.range(o, o + l - 1),
      (int l, _) => ordered.limit(l),
      _ => ordered,
    };

    final rows = await result;
    print(rows);

    return (rows as List)
        .map(
          (row) => MissionRow.fromJson(row as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  /// Partially updates a mission by id using the provided column map.
  Future<MissionRow> update(
    String id,
    Map<String, dynamic> values,
  ) async {
    final response = await _baseQuery
        .update(values)
        .eq(MissionRow.idField, id)
        .select()
        .single();
    return MissionRow.fromJson(response);
  }

  /// Deletes a mission row by id.
  Future<void> delete(String id) async {
    await _baseQuery.delete().eq(MissionRow.idField, id);
  }
}
