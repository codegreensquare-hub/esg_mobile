import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:flutter/material.dart';

class StoryDialog extends StatelessWidget {
  const StoryDialog({
    super.key,
    required this.storyWithTags,
  });

  final StoryWithTags storyWithTags;

  @override
  Widget build(BuildContext context) {
    final story = storyWithTags.story;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return SizedBox.expand(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Hero(
                          tag: 'story-title-${story.id}',
                          child: Text(
                            story.title ?? 'Story',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (story.thumbnailBucket != null &&
                  story.thumbnailFileName != null)
                Hero(
                  tag: 'story-image-${story.id}',
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
                          tag: 'story-subtitle-${story.id}',
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
                    if (storyWithTags.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
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
      ),
    );
  }
}
