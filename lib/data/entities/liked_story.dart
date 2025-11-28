import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class LikedStory {
  final StoryLikeRow like;
  final StoryRow story;
  LikedStory({
    required this.like,
    required this.story,
  });
}
