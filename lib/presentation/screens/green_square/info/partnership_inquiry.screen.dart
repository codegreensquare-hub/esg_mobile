import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquarePartnershipInquiryScreen extends StatelessWidget {
  const GreenSquarePartnershipInquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GreenSquareInfoPage(
      title: '입점 문의',
      children: [
        Text(
          '입점 문의 안내 콘텐츠를 준비 중입니다.',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
