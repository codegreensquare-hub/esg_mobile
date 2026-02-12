import 'package:esg_mobile/presentation/widgets/green_square/faq_card.dart';
import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquareFaqScreen extends StatelessWidget {
  const GreenSquareFaqScreen({super.key});

  static const _items = [
    (
      question: '예산을 어느정도 잡아야할까요?',
      answer: '프로젝트 규모와 참여 인원에 따라 상이합니다. 담당자를 통해 맞춤 견적을 안내해 드립니다.',
    ),
    (
      question: '예산이 과도하게 발생할 수 있을 것 같아 걱정됩니다',
      answer:
          '필요 규모에 맞는 다양한 패키지를 제공하고 있습니다. 예산 범위를 말씀해 주시면 그에 맞는 방안을 제안해 드립니다.',
    ),
    (
      question: '임직원들의 저조한 참여가 걱정됩니다',
      answer: '캠페인 기획 단계부터 참여율을 높일 수 있는 설계와 운영 가이드를 제공합니다. 이전 진행 사례도 공유해 드립니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GreenSquareInfoPage(
      title: '자주 묻는 질문(FAQ)',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _items.length; i++)
              FaqCard(
                question: _items[i].question,
                answer: _items[i].answer,
                showDivider: i < _items.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}
