import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/liked_story.dart';
import 'package:esg_mobile/presentation/widgets/green_square/story_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LikedStoriesDialog extends StatefulWidget {
  const LikedStoriesDialog({super.key});

  @override
  State<LikedStoriesDialog> createState() => _LikedStoriesDialogState();
}

class _LikedStoriesDialogState extends State<LikedStoriesDialog> {
  late List<LikedStory> likedStories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedStories();
  }

  Future<void> _loadLikedStories() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final stories = await StoryService.instance.fetchLikedStories(userId);
      setState(() {
        likedStories = stories;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('좋아요 한 글'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : likedStories.isEmpty
            ? const Center(child: Text('좋아요 한 글이 없습니다.'))
            : ListView.builder(
                itemCount: likedStories.length,
                itemBuilder: (context, index) {
                  final likedStory = likedStories[index];
                  final story = likedStory.story;
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => StoryDialog(
                          story: story,
                          tags: [], // no tags fetched for liked stories
                        ),
                      ),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (story.thumbnailBucket != null &&
                              story.thumbnailFileName != null)
                            Image.network(
                              getImageLink(
                                story.thumbnailBucket!,
                                story.thumbnailFileName!,
                                folderPath: story.thumbnailFolderPath!,
                              ),
                              height: MediaQuery.of(context).size.width * 4 / 5,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.title ?? '',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                if (story.subtitle != null &&
                                    story.subtitle!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      story.subtitle!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                if (story.content != null &&
                                    story.content!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    story.content!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
