import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquareNoticesScreen extends StatelessWidget {
  const GreenSquareNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GreenSquareInfoPage(
      title: '공지사항',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '공지사항 콘텐츠를 준비 중입니다.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
