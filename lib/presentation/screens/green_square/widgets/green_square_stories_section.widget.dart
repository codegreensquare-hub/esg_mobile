import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:flutter/material.dart';

class GreenSquareStoriesSection extends StatefulWidget {
  const GreenSquareStoriesSection({super.key});

  @override
  State<GreenSquareStoriesSection> createState() =>
      _GreenSquareStoriesSectionState();
}

class _GreenSquareStoriesSectionState extends State<GreenSquareStoriesSection> {
  List<StoryWithTags> _stories = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStories();
  }

  Future<void> _fetchStories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await StoryService.instance.fetchStories(
        limit: 10,
      );

      if (!mounted) return;
      setState(() {
        _stories = results;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Error fetching stories: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load stories.';
        _isLoading = false;
      });
    }
  }

  String _resolveStoryImagePath(StoryWithTags item) {
    final bucket = item.story.thumbnailBucket;
    final fileName = item.story.thumbnailFileName;

    if (bucket != null &&
        bucket.isNotEmpty &&
        fileName != null &&
        fileName.isNotEmpty) {
      return getImageLink(
        bucket,
        fileName,
        folderPath: item.story.thumbnailFolderPath,
      );
    }

    return 'assets/images/product_grid/product_1.png'; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 120,
        child: Center(child: Text(_error!)),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          final imageUrl = _resolveStoryImagePath(story);

          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    story.story.title ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
