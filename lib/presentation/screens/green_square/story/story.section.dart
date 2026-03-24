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
    this.selectedFilterTag,
    this.selectedFilterRequestId = 0,
    this.onFilterStateChanged,
  });

  final ScrollController? scrollController;
  final void Function(StoryWithTags)? onTapStory;
  final String? selectedFilterTag;
  final int selectedFilterRequestId;
  final ValueChanged<bool>? onFilterStateChanged;

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
  String? _activeFilter;
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
  void didUpdateWidget(covariant StoriesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasNewFilterRequest =
        oldWidget.selectedFilterRequestId != widget.selectedFilterRequestId;
    if (hasNewFilterRequest && widget.selectedFilterTag != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _toggleFilterByLabel(widget.selectedFilterTag!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Typing manually clears any active static filter.
    if (_activeFilter != null) {
      setState(() {
        _activeFilter = null;
      });
      _notifyFilteredState();
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
      });
      _refreshStories();
    });
  }

  String _normalizeToHashtag(String label) {
    if (label.trim().isEmpty) return label;
    return label.startsWith('#') ? label : '#$label';
  }

  void _notifyFilteredState() {
    widget.onFilterStateChanged?.call(_activeFilter != null);
  }

  void _applyFilter(String label) {
    final normalizedLabel = _normalizeToHashtag(label.trim());
    final keyword = normalizedLabel.startsWith('#')
        ? normalizedLabel.substring(1)
        : normalizedLabel;
    _debounce?.cancel();
    setState(() {
      _activeFilter = normalizedLabel;
      _searchController.text = keyword;
      _searchQuery = keyword;
      _offset = 0;
    });
    _notifyFilteredState();
    _refreshStories();
  }

  void _clearFilter() {
    _debounce?.cancel();
    setState(() {
      _activeFilter = null;
      _searchController.clear();
      _searchQuery = '';
      _offset = 0;
    });
    _notifyFilteredState();
    _refreshStories();
  }

  void _toggleFilterByLabel(String label) {
    final normalizedLabel = _normalizeToHashtag(label.trim());
    if (normalizedLabel.isEmpty) return;
    if (_activeFilter == normalizedLabel) {
      _clearFilter();
    } else {
      _applyFilter(normalizedLabel);
    }
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
    final isFiltered = _activeFilter != null;
    return Column(
      children: [
        if (!isFiltered) ...[
          const SizedBox(height: 16),
          const SupabaseBannerCarousel(appType: 'green_square'),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '키워드 검색',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
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
        ] else ...[
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '친환경 소비를 즐겁게, 자연과 환경을 이롭게 🌿',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Static filter row spanning the available width
        SizedBox(
          height: 40,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _staticFilters.map((label) {
                final bool isActive = _activeFilter == label;
                final Color borderColor =
                    isActive ? const Color(0xFFF3550F) : const Color(0xFFE5E5EA);
                final Color textColor =
                    isActive ? const Color(0xFFF3550F) : const Color(0xFF1C1C1E);
                final Color bgColor =
                    isActive ? const Color(0xFFFFF6F1) : Colors.white;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _toggleFilterByLabel(label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.close,
                              size: 14,
                              color: textColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingMore && _offset == 0)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else
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
                onTagTap: _toggleFilterByLabel,
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
