import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/story_comment_with_user.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/auth/login.screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryDialog extends StatefulWidget {
  const StoryDialog({
    super.key,
    required this.story,
    required this.tags,
  });

  final StoryRow story;
  final List<StoryTagRow> tags;

  @override
  State<StoryDialog> createState() => _StoryDialogState();
}

class _StoryDialogState extends State<StoryDialog> {
  late List<StoryCommentWithUser> comments = [];
  late int likeCount = 0;
  late bool hasLiked = false;
  final TextEditingController _commentController = TextEditingController();
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = Supabase.instance.client.auth.currentUser?.id;
    _loadData();
    // Listen for auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn && userId == null) {
        setState(() {
          userId = event.session?.user.id;
        });
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    final storyId = widget.story.id;
    final fetchedComments = await StoryService.instance.fetchComments(storyId);
    final count = await StoryService.instance.getLikeCount(storyId);
    bool liked = false;
    if (userId != null) {
      liked = await StoryService.instance.hasUserLiked(storyId, userId!);
    }
    setState(() {
      comments = fetchedComments;
      likeCount = count;
      hasLiked = liked;
    });
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to like and comment on stories.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return SizedBox.expand(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Hero(
            tag: 'green-square-story-title-${story.id}',
            child: Text(
              story.title ?? 'Story',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (story.thumbnailBucket != null &&
                  story.thumbnailFileName != null)
                Hero(
                  tag: 'green-square-story-image-${story.id}',
                  child: Image.network(
                    getImageLink(
                      story.thumbnailBucket!,
                      story.thumbnailFileName!,
                      folderPath: story.thumbnailFolderPath!,
                    ),
                    height: screenWidth,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (story.subtitle != null && story.subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Hero(
                          tag: 'green-square-story-subtitle-${story.id}',
                          child: Text(
                            story.subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    if (story.content != null && story.content!.isNotEmpty)
                      Text(
                        story.content!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    if (widget.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: widget.tags
                            .map(
                              (tag) => Chip(label: Text('#${tag.tag ?? ''}')),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            hasLiked ? Icons.favorite : Icons.favorite_border,
                          ),
                          onPressed: userId == null
                              ? () => _showLoginDialog(context)
                              : () async {
                                  await StoryService.instance.toggleLike(
                                    story.id,
                                    userId!,
                                  );
                                  setState(() {
                                    hasLiked = !hasLiked;
                                    likeCount += hasLiked ? 1 : -1;
                                  });
                                },
                        ),
                        Text('$likeCount likes'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final commentWithUser = comments[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person), // placeholder
                          ),
                          title: Text(
                            commentWithUser.commentBy.email ?? 'Anonymous',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(commentWithUser.comment.comment ?? ''),
                              Text(
                                commentWithUser.comment.createdAt.toString(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (userId == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Login to comment',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment',
                        ),
                        onSubmitted: (value) async {
                          if (value.isNotEmpty) {
                            await StoryService.instance.addComment(
                              story.id,
                              userId!,
                              value,
                            );
                            _commentController.clear();
                            await _loadData(); // refetch
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
