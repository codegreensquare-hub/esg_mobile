import 'package:esg_mobile/data/entities/liked_story.dart';
import 'package:esg_mobile/data/entities/story_comment_with_user.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
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
}
