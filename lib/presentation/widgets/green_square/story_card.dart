import 'package:cached_network_image/cached_network_image.dart';
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
  });

  final StoryWithTags storyWithTags;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final story = storyWithTags.story;
    final hasStoryContent =
        (storyWithTags.story.content?.trim().isNotEmpty ?? false);

    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final effectiveWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : screenWidth;
        final imageHeight = effectiveWidth * 4 / 5;

        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => StoryDialog(
                story: storyWithTags.story,
                tags: storyWithTags.tags,
              ),
            ),
          ),
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
                                  child: Text('신고하기'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'report',
                                  child: Text('차단하기'),
                                ),
                              ],
                              onSelected: (value) {
                                // Handle selection here
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
                                        (tag) => Chip(
                                          label: Text('#${tag.tag ?? ''}'),
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
