import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:flutter/material.dart';
import 'package:esg_mobile/presentation/widgets/green_square/text.story.dart';

import 'story_dialog.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.storyWithTags,
    this.borderRadius = 0,
    this.onBlocked,
    this.onUnblocked,
    this.onTap,
    this.onTagTap,
  });

  final StoryWithTags storyWithTags;
  final double borderRadius;
  final Future<void> Function()? onBlocked;
  final Future<void> Function()? onUnblocked;
  final VoidCallback? onTap;
  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final story = storyWithTags.story;
    final hasStoryContent =
        (storyWithTags.story.content?.trim().isNotEmpty ?? false);

    final theme = Theme.of(context);

    if (storyWithTags.isBlocked) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 80, 0, 80),
          child: Column(
            children: [
              const Text('이 게시글은 숨겨졌습니다.'),
              TextButton(
                onPressed: () async {
                  final userId = UserAuthService.instance.currentUser?.id;
                  if (userId == null) return;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('스토리 차단 해제'),
                      content: const Text('이 스토리의 차단을 해제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('해제'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await StoryService.instance.unblockStory(
                      storyId: story.id,
                      userId: userId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('스토리 차단이 해제되었습니다.')),
                      );
                    }
                    await onUnblocked?.call();
                  }
                },
                child: const Text('차단 해제하기'),
              ),
            ],
          ),
        ),
      );
    }

    Future<void> openStoryDialog() async {
      final selectedTag = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => StoryDialog(
            story: storyWithTags.story,
            tags: storyWithTags.tags,
          ),
        ),
      );
      if (selectedTag != null && onTagTap != null) {
        onTagTap!(selectedTag);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final effectiveWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : screenWidth;
        final imageHeight = effectiveWidth * 4 / 5;

        return GestureDetector(
          onTap:
              onTap ??
              openStoryDialog,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (story.thumbnailBucket != null &&
                    story.thumbnailBucket!.isNotEmpty &&
                    story.thumbnailFileName != null &&
                    story.thumbnailFileName!.isNotEmpty)
                  Hero(
                    tag: 'green-square-story-image-${story.id}',
                    child: CachedNetworkImage(
                      imageUrl: getImageLink(
                        story.thumbnailBucket!,
                        story.thumbnailFileName!,
                        folderPath: story.thumbnailFolderPath,
                      ),
                      height: imageHeight,
                      width: effectiveWidth,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        height: imageHeight,
                        width: effectiveWidth,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 2, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Hero(
                                  tag: 'green-square-story-title-${story.id}',
                                  child: Text(
                                    story.title ?? '',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem<String>(
                                  value: 'block',
                                  child: Text('차단하기'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'report',
                                  child: Text('신고하기'),
                                ),
                              ],
                              onSelected: (value) async {
                                if (value == 'block') {
                                  // Block story
                                  final userId =
                                      UserAuthService.instance.currentUser?.id;
                                  if (userId == null) return;

                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('스토리 차단'),
                                      content: const Text('이 스토리를 차단하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('차단'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await StoryService.instance.blockStory(
                                      storyId: story.id,
                                      userId: userId,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('스토리가 차단되었습니다.'),
                                        ),
                                      );
                                    }
                                    await onBlocked?.call();
                                  }
                                } else if (value == 'report') {
                                  // Report story
                                  final userId =
                                      UserAuthService.instance.currentUser?.id;
                                  if (userId == null) return;

                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('스토리 신고'),
                                      content: const Text('이 스토리를 신고하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('신고'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await StoryService.instance.reportStory(
                                      storyId: story.id,
                                      userId: userId,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('신고가 접수되었습니다.'),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      if (story.subtitle != null && story.subtitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                          child: Hero(
                            tag: 'green-square-story-subtitle-${story.id}',
                            child: Text(
                              story.subtitle!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      if (hasStoryContent) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                          child: TextStory(
                            content: storyWithTags.story.content,
                            maxLines: 3,
                          ),
                        ),
                      ],
                      if (storyWithTags.tags.isNotEmpty) ...[
                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 24, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: storyWithTags.tags
                                      .map(
                                        (tag) => InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () {
                                            final raw = (tag.tag ?? '').trim();
                                            if (raw.isEmpty) return;
                                            onTagTap?.call('#$raw');
                                          },
                                          child: Chip(
                                            label: Text('#${tag.tag ?? ''}'),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              // Text for date
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                                child: Text(
                                  '${story.createdAt.year}.${story.createdAt.month}.${story.createdAt.day}',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
