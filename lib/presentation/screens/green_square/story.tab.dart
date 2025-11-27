import 'package:esg_mobile/presentation/screens/green_square/story/story.section.dart';
import 'package:esg_mobile/presentation/widgets/green_square/underline_value.dart';
import 'package:flutter/material.dart';

class StoryTab extends StatefulWidget {
  const StoryTab({super.key});

  @override
  State<StoryTab> createState() => _StoryTabState();
}

class _StoryTabState extends State<StoryTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      controller: _scrollController,
      physics: ClampingScrollPhysics(),
      child: Column(
        children: [
          // trees.png background image
          Container(
            constraints: BoxConstraints(
              maxWidth: double.infinity,
              minHeight: 200,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/trees.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.fromLTRB(24, 60, 24, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '🌳 마일리지로 응원한 친환경 소비',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: OvalBorder(
                        side: BorderSide(color: Colors.white, width: 0.8),
                      ),
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      '99,999,999원',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 42),
                Text(
                  '그리더들이 함께한 친환경 인증',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: OvalBorder(
                        side: BorderSide(color: Colors.white, width: 0.8),
                      ),
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      '99,999,999원',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UnderlineValue(
                          title: '대중교통 이용하기',
                          value: 12345,
                        ),
                        UnderlineValue(
                          title: '텀블러 사용하기',
                          value: 55658,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UnderlineValue(
                          title: '분리배출 하기',
                          value: 543210,
                        ),
                        UnderlineValue(
                          title: '재사용가방 활용하기',
                          value: 321098,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Main Content
          StoriesSection(scrollController: _scrollController),
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
