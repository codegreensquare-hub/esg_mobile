import 'package:esg_mobile/data/entities/blocked_report_comment_entry.dart';
import 'package:esg_mobile/data/entities/liked_story.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/entities/story_comment_with_user.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:esg_mobile/data/models/supabase/database.dart';

class StoryService {
  StoryService._internal({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  static final StoryService _instance = StoryService._internal();

  static StoryService get instance => _instance;

  final SupabaseClient _client;

  Future<List<StoryWithTags>> fetchStories({
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final trimmedSearch = search?.trim() ?? '';

    // Base query: published stories, searchable by title/subtitle/content.
    PostgrestFilterBuilder baseQuery = _client
        .from(StoryTable().tableName)
        .select('*, story_tag(*)')
        .eq(StoryRow.isPublishedField, true);

    if (trimmedSearch.isNotEmpty) {
      final pattern = '%$trimmedSearch%';
      baseQuery = baseQuery.or(
        'title.ilike.$pattern,'
        'subtitle.ilike.$pattern,'
        'content.ilike.$pattern',
      );
    }

    // Fetch primary matches (title/subtitle/content) with server-side paging
    final primaryResponse = await baseQuery
        .order(StoryRow.createdAtField, ascending: false)
        .range(offset, offset + limit - 1);

    List<Map<String, dynamic>> combined =
        (primaryResponse as List).whereType<Map<String, dynamic>>().toList();

    // When there is a search term, also fetch stories whose tags match, then
    // merge them client-side to provide a unified search experience.
    if (trimmedSearch.isNotEmpty) {
      final pattern = '%$trimmedSearch%';

      final tagRows = await _client
          .from(StoryTagTable().tableName)
          .select(StoryTagRow.storyField)
          .ilike(StoryTagRow.tagField, pattern);

      final tagStoryIds = (tagRows as List)
          .whereType<Map<String, dynamic>>()
          .map((row) => row[StoryTagRow.storyField] as String?)
          .whereType<String>()
          .toList(growable: false);

      if (tagStoryIds.isNotEmpty) {
        final tagStoriesResponse = await _client
            .from(StoryTable().tableName)
            .select('*, story_tag(*)')
            .eq(StoryRow.isPublishedField, true)
            .inFilter(StoryRow.idField, tagStoryIds)
            .order(StoryRow.createdAtField, ascending: false);

        final tagStories = (tagStoriesResponse as List)
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);

        // Merge, de-duplicating by story id and then slicing to the desired window.
        final seenIds = <String>{};
        final merged = <Map<String, dynamic>>[];

        void addAll(List<Map<String, dynamic>> source) {
          for (final json in source) {
            final id = json[StoryRow.idField] as String?;
            if (id == null || seenIds.contains(id)) continue;
            seenIds.add(id);
            merged.add(json);
          }
        }

        addAll(combined);
        addAll(tagStories);

        // Apply offset/limit on the merged result to approximate unified paging.
        combined = merged.skip(offset).take(limit).toList(growable: false);
      }
    }

    debugPrint('Fetched stories (combined) count: ${combined.length}');

    return combined.map((json) {
      final story = StoryRow.fromJson(json);
      final tags =
          (json[StoryTagTable().tableName] as List?)
              ?.map((tagJson) => StoryTagRow.fromJson(tagJson))
              .toList() ??
          [];
      return StoryWithTags(story: story, tags: tags);
    }).toList();
  }

  Future<List<StoryCommentWithUser>> fetchComments(String storyId) async {
    final response = await _client
        .from(StoryCommentTable().tableName)
        .select('*, user(*)')
        .eq(StoryCommentRow.storyField, storyId)
        .order(StoryCommentRow.createdAtField);
    return (response as List).map((json) {
      final comment = StoryCommentRow.fromJson(json);
      final user = UserRow.fromJson(json['user']);
      return StoryCommentWithUser(comment: comment, commentBy: user);
    }).toList();
  }

  Future<List<StoryCommentRow>> fetchCommentsByUser(String userId) async {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) {
      return const <StoryCommentRow>[];
    }

    final response = await _client
        .from(StoryCommentTable().tableName)
        .select()
        .eq(StoryCommentRow.commentByField, trimmed)
        .order(StoryCommentRow.createdAtField, ascending: false);

    return (response as List)
        .whereType<Map<String, dynamic>>()
        .map(StoryCommentRow.fromJson)
        .toList(growable: false);
  }

  Future<StoryWithTags?> fetchStoryWithTagsById(String storyId) async {
    final trimmed = storyId.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final json = await _client
        .from(StoryTable().tableName)
        .select('*, story_tag(*)')
        .eq(StoryRow.idField, trimmed)
        .maybeSingle();

    if (json is! Map<String, dynamic>) {
      return null;
    }

    final story = StoryRow.fromJson(json);
    final tags =
        (json[StoryTagTable().tableName] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(StoryTagRow.fromJson)
            .toList(growable: false) ??
        const <StoryTagRow>[];

    return StoryWithTags(story: story, tags: tags);
  }

  Future<int> getLikeCount(String storyId) async {
    final response = await _client
        .from(StoryLikeTable().tableName)
        .select(StoryLikeRow.idField)
        .eq(StoryLikeRow.storyField, storyId)
        .count(CountOption.exact);
    return response.count;
  }

  Future<bool> hasUserLiked(String storyId, String userId) async {
    final response = await _client
        .from(StoryLikeTable().tableName)
        .select()
        .eq(StoryLikeRow.storyField, storyId)
        .eq(StoryLikeRow.likedByField, userId);
    return response.isNotEmpty;
  }

  Future<void> toggleLike(String storyId, String userId) async {
    final hasLiked = await hasUserLiked(storyId, userId);
    if (hasLiked) {
      await _client
          .from(StoryLikeTable().tableName)
          .delete()
          .eq(StoryLikeRow.storyField, storyId)
          .eq(StoryLikeRow.likedByField, userId);
    } else {
      await _client.from(StoryLikeTable().tableName).insert({
        StoryLikeRow.storyField: storyId,
        StoryLikeRow.likedByField: userId,
      });
    }
  }

  Future<void> addComment(String storyId, String userId, String comment) async {
    await _client.from(StoryCommentTable().tableName).insert({
      StoryCommentRow.storyField: storyId,
      StoryCommentRow.commentByField: userId,
      StoryCommentRow.commentField: comment,
      StoryCommentRow.createdAtField: DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteComment(String commentId) async {
    final trimmed = commentId.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await _client
        .from(StoryCommentTable().tableName)
        .delete()
        .eq(StoryCommentRow.idField, trimmed);
  }

  Future<void> updateComment(String commentId, String newComment) async {
    final trimmedId = commentId.trim();
    final trimmedComment = newComment.trim();
    if (trimmedId.isEmpty || trimmedComment.isEmpty) {
      return;
    }

    await _client
        .from(StoryCommentTable().tableName)
        .update({StoryCommentRow.commentField: trimmedComment})
        .eq(StoryCommentRow.idField, trimmedId);
  }

  Future<List<LikedStory>> fetchLikedStories(String userId) async {
    final response = await _client
        .from(StoryLikeTable().tableName)
        .select('*, story(*)')
        .eq(StoryLikeRow.likedByField, userId);
    return (response as List).map((json) {
      final like = StoryLikeRow.fromJson(json);
      final story = StoryRow.fromJson(json['story']);
      return LikedStory(like: like, story: story);
    }).toList();
  }

  Future<List<ProductWithOtherDetails>> fetchRelatedProducts(
    String storyId, {
    String? userId,
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from(StoryRelatedProductTable().tableName)
          .select(
            '${StoryRelatedProductRow.productField}, ${StoryRelatedProductRow.createdAtField}',
          )
          .eq(StoryRelatedProductRow.storyField, storyId)
          .order(StoryRelatedProductRow.createdAtField, ascending: true);

      final productIds = (response as List)
          .whereType<Map<String, dynamic>>()
          .map((row) => row[StoryRelatedProductRow.productField] as String)
          .toList();

      if (productIds.isEmpty) {
        return [];
      }

      final products = await ProductService.instance.fetchProductsByIds(
        productIds: productIds,
        userId: userId,
        limit: limit,
      );

      return products;
    } catch (e) {
      // Keep story dialog resilient; just return empty.
      // ignore: avoid_print
      print('Error fetching related products: $e');
      return [];
    }
  }

  Future<List<MissionRow>> fetchRelatedMissions(
    String storyId, {
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from(StoryRelatedMissionTable().tableName)
          .select(
            '${StoryRelatedMissionRow.missionField}, ${StoryRelatedMissionRow.createdAtField}',
          )
          .eq(StoryRelatedMissionRow.storyField, storyId)
          .order(StoryRelatedMissionRow.createdAtField, ascending: true);

      final missionIds = (response as List)
          .whereType<Map<String, dynamic>>()
          .map((row) => row[StoryRelatedMissionRow.missionField] as String)
          .toList();

      if (missionIds.isEmpty) {
        return [];
      }

      final uniqueIds = missionIds.toSet().toList();
      final missionsResponse = await _client
          .from(MissionTable().tableName)
          .select('*')
          .inFilter(MissionRow.idField, uniqueIds);

      final missions = (missionsResponse as List)
          .whereType<Map<String, dynamic>>()
          .map(MissionRow.fromJson)
          .toList();

      final indexById = missionIds.asMap().map(
        (index, id) => MapEntry(id, index),
      );

      missions.sort(
        (a, b) =>
            (indexById[a.id] ?? 1 << 30).compareTo(indexById[b.id] ?? 1 << 30),
      );

      return missions.take(limit).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching related missions: $e');
      return [];
    }
  }

  Future<List<StoryWithTags>> fetchPreviousStories(
    StoryRow currentStory, {
    int limit = 4,
  }) async {
    try {
      final response = await _client
          .from(StoryTable().tableName)
          .select('*, story_tag(*)')
          .eq(StoryRow.isPublishedField, true)
          .neq(StoryRow.idField, currentStory.id)
          .lt(
            StoryRow.createdAtField,
            currentStory.createdAt.toUtc().toIso8601String(),
          )
          .order(StoryRow.createdAtField, ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final story = StoryRow.fromJson(json);
        final tags =
            (json[StoryTagTable().tableName] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(StoryTagRow.fromJson)
                .toList() ??
            [];
        return StoryWithTags(story: story, tags: tags);
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching previous stories: $e');
      return [];
    }
  }

  Future<List<String>> fetchBlockedStoryIds(String userId) async {
    final response = await _client
        .from(StoryBlockedTable().tableName)
        .select(StoryBlockedRow.storyField)
        .eq(StoryBlockedRow.blockerField, userId);
    return (response as List)
        .map((e) => e[StoryBlockedRow.storyField] as String)
        .toList();
  }

  Future<void> blockStory({
    required String storyId,
    required String userId,
  }) async {
    await _client.from(StoryBlockedTable().tableName).insert({
      StoryBlockedRow.storyField: storyId,
      StoryBlockedRow.blockerField: userId,
    });
  }

  Future<void> unblockStory({
    required String storyId,
    required String userId,
  }) async {
    await _client
        .from(StoryBlockedTable().tableName)
        .delete()
        .eq(StoryBlockedRow.storyField, storyId)
        .eq(StoryBlockedRow.blockerField, userId);
  }

  Future<void> reportStory({
    required String storyId,
    required String userId,
  }) async {
    await _client.from(ReportTable().tableName).insert({
      ReportRow.reporterField: userId,
      ReportRow.storyReportedField: storyId,
    });
  }

  Future<void> blockComment({
    required String commentId,
    required String userId,
  }) async {
    await _client.from(CommentBlockedTable().tableName).insert({
      CommentBlockedRow.blockerField: userId,
      CommentBlockedRow.commentBlockedField: commentId,
    });
  }

  Future<void> unblockComment({
    required String commentId,
    required String userId,
  }) async {
    await _client
        .from(CommentBlockedTable().tableName)
        .delete()
        .eq(CommentBlockedRow.commentBlockedField, commentId)
        .eq(CommentBlockedRow.blockerField, userId);
  }

  /// Returns comment IDs that [userId] has blocked.
  Future<List<String>> fetchBlockedCommentIds(String userId) async {
    final response = await _client
        .from(CommentBlockedTable().tableName)
        .select(CommentBlockedRow.commentBlockedField)
        .eq(CommentBlockedRow.blockerField, userId);
    return (response as List)
        .map<String>(
            (e) => e[CommentBlockedRow.commentBlockedField] as String)
        .toList();
  }

  static String _maskDisplayName(String? username, String? email) {
    final raw = username?.trim() ?? email?.trim() ?? '';
    if (raw.isEmpty) return '***';
    if (raw.length == 1) return '$raw**';
    return '${raw[0]}**';
  }

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y.$m.$day';
  }

  /// Fetches blocked comment history for [userId], ordered by created_at desc.
  Future<List<BlockedReportCommentEntry>> fetchBlockedCommentHistory(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final rows = await _client
        .from(CommentBlockedTable().tableName)
        .select('id, created_at, ${CommentBlockedRow.commentBlockedField}')
        .eq(CommentBlockedRow.blockerField, userId)
        .order(CommentBlockedRow.createdAtField, ascending: false)
        .range(offset, offset + limit - 1);
    final list = rows as List;
    if (list.isEmpty) return [];
    final commentIds =
        list
            .map<String>(
                (e) => e[CommentBlockedRow.commentBlockedField] as String)
            .toList();
    final comments = await _client
        .from(StoryCommentTable().tableName)
        .select('*, user:comment_by(username, email)')
        .inFilter(StoryCommentRow.idField, commentIds);
    final commentMap = <String, Map<String, dynamic>>{};
    for (final c in comments as List) {
      final id = c[StoryCommentRow.idField] as String?;
      if (id != null) commentMap[id] = c as Map<String, dynamic>;
    }
    final result = <BlockedReportCommentEntry>[];
    for (final row in list) {
      final commentId = row[CommentBlockedRow.commentBlockedField] as String?;
      if (commentId == null) continue;
      final commentData = commentMap[commentId];
      if (commentData == null) continue;
      final userData = commentData['user'];
      final username = userData is Map ? userData['username'] as String? : null;
      final email = userData is Map ? userData['email'] as String? : null;
      final createdAt = commentData[StoryCommentRow.createdAtField];
      final dateStr = createdAt != null
          ? _formatDate(DateTime.parse(createdAt.toString()))
          : '';
      result.add(BlockedReportCommentEntry(
        commentId: commentId,
        maskedName: _maskDisplayName(username, email),
        date: dateStr,
        commentText:
            (commentData[StoryCommentRow.commentField] as String?) ?? '',
        isBlocked: true,
      ));
    }
    return result;
  }

  /// Fetches reported comment history for [userId], ordered by created_at desc.
  Future<List<BlockedReportCommentEntry>> fetchReportedCommentHistory(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final rows = await _client
        .from(CommentReportedTable().tableName)
        .select('id, created_at, ${CommentReportedRow.commentReportedField}')
        .eq(CommentReportedRow.reporterField, userId)
        .order(CommentReportedRow.createdAtField, ascending: false)
        .range(offset, offset + limit - 1);
    final list = rows as List;
    if (list.isEmpty) return [];
    final commentIds =
        list
            .map<String>(
                (e) => e[CommentReportedRow.commentReportedField] as String)
            .toList();
    final comments = await _client
        .from(StoryCommentTable().tableName)
        .select('*, user:comment_by(username, email)')
        .inFilter(StoryCommentRow.idField, commentIds);
    final commentMap = <String, Map<String, dynamic>>{};
    for (final c in comments as List) {
      final id = c[StoryCommentRow.idField] as String?;
      if (id != null) commentMap[id] = c as Map<String, dynamic>;
    }
    final result = <BlockedReportCommentEntry>[];
    for (final row in list) {
      final commentId =
          row[CommentReportedRow.commentReportedField] as String?;
      if (commentId == null) continue;
      final commentData = commentMap[commentId];
      if (commentData == null) continue;
      final userData = commentData['user'];
      final username = userData is Map ? userData['username'] as String? : null;
      final email = userData is Map ? userData['email'] as String? : null;
      final createdAt = commentData[StoryCommentRow.createdAtField];
      final dateStr = createdAt != null
          ? _formatDate(DateTime.parse(createdAt.toString()))
          : '';
      result.add(BlockedReportCommentEntry(
        commentId: commentId,
        maskedName: _maskDisplayName(username, email),
        date: dateStr,
        commentText:
            (commentData[StoryCommentRow.commentField] as String?) ?? '',
        isBlocked: false,
      ));
    }
    return result;
  }

  Future<void> reportComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      await _client.from(CommentReportedTable().tableName).insert({
        CommentReportedRow.reporterField: userId,
        CommentReportedRow.commentReportedField: commentId,
      });
    } on PostgrestException catch (e) {
      // Ignore duplicate reports from the same user for the same comment.
      // The unique (reporter, comment_reported) constraint will raise a 23505 error.
      if (e.code == '23505') {
        return;
      }
      rethrow;
    }
  }
}
