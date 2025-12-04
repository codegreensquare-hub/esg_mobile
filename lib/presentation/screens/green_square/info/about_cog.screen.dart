import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquareAboutCogScreen extends StatelessWidget {
  const GreenSquareAboutCogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GreenSquareInfoPage(
      title: '콕(cog) 에 관하여',
      children: [
        Text(
          '콕(cog)에 대한 소개 콘텐츠를 준비 중입니다.',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
