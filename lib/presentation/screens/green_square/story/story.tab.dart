import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:esg_mobile/presentation/screens/green_square/story/story.section.dart';
import 'package:esg_mobile/presentation/widgets/green_square/green_square_statistics_banner.dart';
import 'package:flutter/material.dart';

class StoryTab extends StatefulWidget {
  const StoryTab({super.key, this.onTapStory});

  final void Function(StoryWithTags)? onTapStory;

  @override
  State<StoryTab> createState() => _StoryTabState();
}

class _StoryTabState extends State<StoryTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          const GreenSquareStatisticsBanner(),
          // Main Content
          StoriesSection(
            scrollController: _scrollController,
            onTapStory: widget.onTapStory,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
