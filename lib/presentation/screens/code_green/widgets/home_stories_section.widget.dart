import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:esg_mobile/presentation/screens/code_green/widgets/home_story_card.widget.dart';
import 'package:flutter/material.dart';

class HomeStoriesSection extends StatefulWidget {
  const HomeStoriesSection({
    super.key,
    this.onTapStory,
  });

  final void Function(StoryWithTags story)? onTapStory;

  @override
  State<HomeStoriesSection> createState() => _HomeStoriesSectionState();
}

class _HomeStoriesSectionState extends State<HomeStoriesSection> {
  List<StoryWithTags> _stories = const [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  final ScrollController _scrollController = ScrollController();

  int _offset = 0;
  static const int _limit = 10;
  static const double _storyCardWidth = 220;
  static const double _storyImageHeight = 170;
  static const double _storyCardHeight = 270;
  static const double _sectionTitleSpacing = 16;
  static const double _storyCardShadowPadding = 12;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchStories(reset: true);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (!_hasMore || _isLoading || _isLoadingMore) return;

    final position = _scrollController.position;
    final shouldLoadMore = position.pixels >= (position.maxScrollExtent - 200);
    if (shouldLoadMore) {
      _fetchStories();
    }
  }

  Future<void> _fetchStories({bool reset = false}) async {
    if (!reset && (_isLoading || _isLoadingMore)) return;
    if (reset && _isLoadingMore) return;

    if (reset) {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _hasMore = true;
        _error = null;
        _stories = const [];
        _offset = 0;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _error = null;
      });
    }

    try {
      final results = await StoryService.instance.fetchStories(
        limit: _limit,
        offset: _offset,
      );

      final resultsWithImages = results
          .where(
            (item) =>
                (item.story.thumbnailBucket?.isNotEmpty ?? false) &&
                (item.story.thumbnailFileName?.isNotEmpty ?? false),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _stories = [..._stories, ...resultsWithImages];
        _offset += results.length;
        if (results.length < _limit) {
          _hasMore = false;
        }

        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Error fetching stories: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load stories.';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width >= 900
            ? 120.0
            : width >= 600
            ? 64.0
            : width >= 430
            ? 24.0
            : 16.0;

        final isWide = width >= 600;

        Widget content;
        if (_isLoading) {
          content = SizedBox(
            height: _storyCardHeight + (_storyCardShadowPadding * 2),
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (_error != null) {
          content = SizedBox(
            height: _storyCardHeight + (_storyCardShadowPadding * 2),
            child: Center(child: Text(_error!)),
          );
        } else {
          content = SizedBox(
            height: _storyCardHeight + (_storyCardShadowPadding * 2),
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                _storyCardShadowPadding,
                horizontalPadding,
                _storyCardShadowPadding,
              ),
              itemCount: _stories.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                if (index >= _stories.length) {
                  return const SizedBox(
                    width: _storyCardWidth,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final story = _stories[index];
                return SizedBox(
                  width: _storyCardWidth,
                  height: _storyCardHeight,
                  child: HomeStoryCard(
                    storyWithTags: story,
                    imageHeight: _storyImageHeight,
                    onTap: widget.onTapStory == null
                        ? null
                        : () => widget.onTapStory!.call(story),
                  ),
                );
              },
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Square Story',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: _sectionTitleSpacing),
            content,
          ],
        );
      },
    );
  }
}
