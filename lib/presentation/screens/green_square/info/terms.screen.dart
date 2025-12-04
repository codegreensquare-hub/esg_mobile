import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquareTermsScreen extends StatelessWidget {
  const GreenSquareTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GreenSquareInfoPage(
      title: '스퀘어 이용 약관',
      children: [
        Text(
          '스퀘어 이용 약관 콘텐츠를 준비 중입니다.',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
