import 'package:esg_mobile/data/models/supabase/tables/story_comment.dart';
import 'package:esg_mobile/data/models/supabase/tables/user.dart';

class StoryCommentWithUser {
  final StoryCommentRow comment;
  final UserRow commentBy;

  StoryCommentWithUser({
    required this.comment,
    required this.commentBy,
  });
}
