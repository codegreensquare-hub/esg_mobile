import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:flutter/material.dart';
import 'package:esg_mobile/presentation/widgets/green_square/text.story.dart';

import 'story_dialog.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.storyWithTags,
  });

  final StoryWithTags storyWithTags;

  @override
  Widget build(BuildContext context) {
    final story = storyWithTags.story;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final hasStoryContent =
        (storyWithTags.story.content?.trim().isNotEmpty ?? false);

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
          borderRadius: BorderRadius.circular(0),
        ),
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
                  height: screenWidth * 4 / 5,
                  width: screenWidth,
                  fit: BoxFit.cover,
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
                          .map((tag) => Chip(label: Text('#${tag.tag ?? ''}')))
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
  }
}
