import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:esg_mobile/presentation/widgets/logo/green_square.logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GreenSquarePartnershipInquiryScreen extends StatelessWidget {
  const GreenSquarePartnershipInquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GreenSquareInfoPage(
      backgroundColor: const Color(0xFF355149),
      title: '입점 문의',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: GreenSquareLogo(height: 30, color: Colors.white)),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  height: 1,
                  width: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '그린 스퀘어는 가치 있는 소비를 위한\n친환경 전문 플랫폼입니다.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '지구를 위한 선한 영향력을 위해\n일하는 기업이라면 언제든 환영입니다.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '함께 하길 원하실 경우 아래 입점 양식을 작성하여\n메일로 보내주시기 바랍니다.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'sup.ceo@codegreen.io',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '제안해주신 내용에 대해서는\n가급적 빠른 시일 내 답변 드리도록 하겠습니다.\n(입점이 어려울 경우 별도의 회신이 없을 수 있습니다.)',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => throw UnimplementedError(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.white),
                          ),
                        ),
                        child: const Text('입점 양식 다운받기'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => throw UnimplementedError(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.white),
                          ),
                        ),
                        child: const Text('입점사 관리자 로그인'),
                      ),
                    ),
                    const SizedBox(height: 42),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
