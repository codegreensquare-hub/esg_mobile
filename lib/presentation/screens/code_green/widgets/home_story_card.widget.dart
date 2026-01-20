import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:flutter/material.dart';

import 'package:esg_mobile/presentation/widgets/green_square/story_dialog.dart';

class HomeStoryCard extends StatelessWidget {
  const HomeStoryCard({
    super.key,
    required this.storyWithTags,
    this.borderRadius = 16,
    required this.imageHeight,
    this.onTap,
  });

  final StoryWithTags storyWithTags;
  final double borderRadius;
  final double imageHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final story = storyWithTags.story;

    final bucket = story.thumbnailBucket;
    final fileName = story.thumbnailFileName;
    if (bucket == null ||
        bucket.isEmpty ||
        fileName == null ||
        fileName.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final effectiveWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : screenWidth;

        return GestureDetector(
          onTap:
              onTap ??
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => StoryDialog(
                    story: story,
                    tags: storyWithTags.tags,
                  ),
                ),
              ),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'green-square-story-image-${story.id}',
                  child: CachedNetworkImage(
                    imageUrl: getImageLink(
                      bucket,
                      fileName,
                      folderPath: story.thumbnailFolderPath,
                    ),
                    height: imageHeight,
                    width: effectiveWidth,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: imageHeight,
                      width: effectiveWidth,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                        ),
                        if (story.subtitle != null &&
                            story.subtitle!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              story.subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    height: 1.15,
                                  ),
                            ),
                          ),
                      ],
                    ),
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
