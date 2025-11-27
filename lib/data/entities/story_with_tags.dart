import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class StoryWithTags {
  final StoryRow story;
  final List<StoryTagRow> tags;

  StoryWithTags({required this.story, required this.tags});
}
