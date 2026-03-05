import 'dart:async';

import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:esg_mobile/presentation/widgets/green_square/story_card.dart';
import 'package:esg_mobile/presentation/widgets/main/auto_image_banner_carousel.dart';
import 'package:flutter/material.dart';

class StoriesSection extends StatefulWidget {
  const StoriesSection({
    super.key,
    this.scrollController,
    this.onTapStory,
  });

  final ScrollController? scrollController;
  final void Function(StoryWithTags)? onTapStory;

  @override
  State<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<StoriesSection> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool _hasMore = true;

  final List<StoryWithTags> _stories = [];
  bool _isLoadingMore = false;
  String _searchQuery = '';
  int _offset = 0;
  static const int _limit = 20;
  static const List<String> _staticFilters = [
    '#리필스테이션',
    '#제로웨이스트샵',
    '#친환경',
    '#비거니즘',
    '#제로웨이스트',
  ];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
      });
      _refreshStories();
    });
  }

  Future<List<StoryWithTags>> _fetchStories() async {
    final userId = UserAuthService.instance.currentUser?.id;
    final blockedIds = userId != null
        ? await StoryService.instance.fetchBlockedStoryIds(userId)
        : [];
    final newStories = await StoryService.instance.fetchStories(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      limit: _limit,
      offset: _offset,
    );
    final filteredStories = newStories
        .map(
          (s) => StoryWithTags(
            story: s.story,
            tags: s.tags,
            isBlocked: blockedIds.contains(s.story.id),
          ),
        )
        .toList();
    return filteredStories;
  }

  Future<void> _loadStories() async {
    if (_isLoadingMore) return;
    if (!mounted) return;
    setState(() => _isLoadingMore = true);
    try {
      final filteredStories = await _fetchStories();
      if (!mounted) return;
      _stories.addAll(filteredStories);
      _offset += filteredStories.length;
      if (filteredStories.length < _limit) {
        // No more stories to load
        _hasMore = false;
      }
      _isLoadingMore = false;
      setState(() {});
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshStories() async {
    if (!mounted) return;
    setState(() => _isLoadingMore = true);
    _offset = 0;
    try {
      final filteredStories = await _fetchStories();
      if (!mounted) return;
      _stories.clear();
      _stories.addAll(filteredStories);
      _offset = filteredStories.length;
      _hasMore = filteredStories.length >= _limit;
      _isLoadingMore = false;
      setState(() {});
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _loadMore() async {
    if (!_hasMore) return;
    if (_isLoadingMore) return;
    await _loadStories();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        AutoImageBannerCarousel(
          assetImagePaths: const [
            'assets/images/about/about_1.7a6b64fe.jpg',
            'assets/images/about/about_2.a32a1d4b.jpg',
            'assets/images/about/about_4.5918b406.jpg',
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '키워드 검색',
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Static filter row spanning the available width
        SizedBox(
          height: 40,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _staticFilters
                  .map(
                    (label) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFE5E5EA),
                          ),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _stories.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _stories.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final story = _stories[index];
            if (index == _stories.length - 1 && !_isLoadingMore) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _loadMore(),
              );
            }
            return StoryCard(
              storyWithTags: story,
              onBlocked: _refreshStories,
              onUnblocked: _refreshStories,
              onTap: widget.onTapStory != null
                  ? () => widget.onTapStory!(story)
                  : null,
            );
          },
        ),
      ],
    );
  }
}
