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
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'green-square-story-title-${story.id}',
                        child: Text(
                          story.title ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (story.subtitle != null && story.subtitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
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
                        TextStory(
                          content: storyWithTags.story.content,
                          maxLines: 3,
                        ),
                      ],
                      if (storyWithTags.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: storyWithTags.tags
                              .map(
                                (tag) => Chip(label: Text('#${tag.tag ?? ''}')),
                              )
                              .toList(),
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
    );
  }
}
