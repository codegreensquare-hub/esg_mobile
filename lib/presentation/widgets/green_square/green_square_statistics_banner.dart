import 'package:esg_mobile/presentation/widgets/green_square/underline_value.dart';
import 'package:flutter/material.dart';

class GreenSquareStatisticsBanner extends StatelessWidget {
  const GreenSquareStatisticsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
        minHeight: 200,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/backgrounds/trees.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
        ),
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
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
                shadows: const [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: ShapeDecoration(
                  shape: OvalBorder(
                    side: const BorderSide(color: Colors.white, width: 0.8),
                  ),
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(
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
                    shadows: const [
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
            const SizedBox(height: 42),
            Text(
              '그리더들이 함께한 친환경 인증',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: ShapeDecoration(
                  shape: OvalBorder(
                    side: const BorderSide(color: Colors.white, width: 0.8),
                  ),
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(
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
                    shadows: const [
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
    );
  }
}
