import 'package:flutter/material.dart';

class StoryTab extends StatelessWidget {
  const StoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Green Square Story Tab',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
