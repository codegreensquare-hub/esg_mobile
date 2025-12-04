import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquareContactScreen extends StatelessWidget {
  const GreenSquareContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GreenSquareInfoPage(
      title: '문의하기',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문의하기 콘텐츠를 준비 중입니다.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
