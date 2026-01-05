import 'package:esg_mobile/data/entities/liked_story.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/entities/story_comment_with_user.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
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
    PostgrestFilterBuilder query = _client
        .from(StoryTable().tableName)
        .select('*, story_tag(*)');

    // Only fetch published stories
    query = query.eq(StoryRow.isPublishedField, true);

    if (search != null && search.isNotEmpty) {
      query = query.or(
        'title.ilike.%$search%,subtitle.ilike.%$search%,content.ilike.%$search%',
      );
    }

    final response = await query
        .order(StoryRow.createdAtField, ascending: false)
        .range(offset, offset + limit - 1);

    print('Fetched stories response: $response');

    return (response as List).map((json) {
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
}
