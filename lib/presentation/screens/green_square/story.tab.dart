import 'package:flutter/material.dart';

class StoryTab extends StatelessWidget {
  const StoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // trees.png background image
          Container(
            // height: 200, // Add height to make background visible
            constraints: BoxConstraints(
              maxWidth: double.infinity,
              minHeight: 200,
            ),
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/trees.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '🌳 마일리지로 응원한 친환경 소비',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Make text white for visibility
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8),
                // This text must be in an oval with white border
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      '43,286,951원',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Make text white for visibility
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
              ],
            ),
          ),
          // Main Content
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: const Text(
              '그린스퀘어는 여러분의 친환경 활동을 응원합니다!  함께 지구를 지키는 작은 습관들을 공유하고,  더 나은 세상을 만들어가요.  여러분의 이야기가 그린스퀘어의 힘이 됩니다! ',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
