import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquarePrivacyPolicyScreen extends StatelessWidget {
  const GreenSquarePrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GreenSquareInfoPage(
      title: '개인정보 처리방침',
      children: [
        Text(
          '개인정보 처리방침 콘텐츠를 준비 중입니다.',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
