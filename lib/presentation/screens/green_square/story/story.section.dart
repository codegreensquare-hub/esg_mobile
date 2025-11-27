import 'dart:async';

import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:esg_mobile/presentation/widgets/green_square/story_card.dart';
import 'package:flutter/material.dart';

class StoriesSection extends StatefulWidget {
  const StoriesSection({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

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
        _stories.clear();
        _offset = 0;
      });
      _loadStories();
    });
  }

  Future<void> _loadStories() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final newStories = await StoryService.instance.fetchStories(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        limit: _limit,
        offset: _offset,
      );

      _stories.addAll(newStories);
      _offset += newStories.length;
      if (newStories.length < _limit) {
        // No more stories to load
        _hasMore = false;
      }
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
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '스토리 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
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
              return StoryCard(storyWithTags: story);
            },
          ),
        ],
      ),
    );
  }
}
