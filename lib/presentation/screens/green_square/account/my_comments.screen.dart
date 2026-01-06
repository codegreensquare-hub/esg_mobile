import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/widgets/green_square/story_dialog.dart';
import 'package:flutter/material.dart';

class MyCommentsScreen extends StatefulWidget {
  const MyCommentsScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<MyCommentsScreen> createState() => _MyCommentsScreenState();
}

class _MyCommentsScreenState extends State<MyCommentsScreen> {
  late final Future<List<StoryCommentRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = StoryService.instance.fetchCommentsByUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 쓴 댓글'),
      ),
      body: FutureBuilder<List<StoryCommentRow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LinearProgressIndicator();
          }

          if (snapshot.hasError) {
            debugPrint('Error fetching my comments: ${snapshot.error}');
            return Center(
              child: Text(
                '${snapshot.error}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.error,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final items = snapshot.data ?? const <StoryCommentRow>[];

          if (items.isEmpty) {
            return Center(
              child: Text(
                '작성한 댓글이 없습니다.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final comment = items[index];
              final commentText = (comment.comment ?? '').trim();
              final createdText = comment.createdAt
                  .toLocal()
                  .toString()
                  .split('.')
                  .first;
              final storyId = (comment.story ?? '').trim();

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: storyId.isEmpty
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          try {
                            final storyWithTags = await StoryService.instance
                                .fetchStoryWithTagsById(storyId);
                            if (!mounted) return;

                            if (storyWithTags == null) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('스토리를 찾을 수 없습니다.'),
                                ),
                              );
                              return;
                            }

                            navigator.pop();
                            await Future<void>.delayed(Duration.zero);
                            navigator.push(
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => StoryDialog(
                                  story: storyWithTags.story,
                                  tags: storyWithTags.tags,
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('오류가 발생했습니다: $e'),
                              ),
                            );
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commentText.isEmpty ? '내용이 없습니다.' : commentText,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                storyId.isEmpty ? '' : '스토리: $storyId',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              createdText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
