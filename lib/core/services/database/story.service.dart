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
        .from('story')
        .select('*, story_tag(*)');

    // Only fetch published stories
    query = query.eq('is_published', true);

    if (search != null && search.isNotEmpty) {
      query = query.or(
        'title.ilike.%$search%,subtitle.ilike.%$search%,content.ilike.%$search%',
      );
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    print('Fetched stories response: $response');

    return (response as List).map((json) {
      final story = StoryRow.fromJson(json);
      final tags =
          (json['story_tag'] as List?)
              ?.map((tagJson) => StoryTagRow.fromJson(tagJson))
              .toList() ??
          [];
      return StoryWithTags(story: story, tags: tags);
    }).toList();
  }
}
