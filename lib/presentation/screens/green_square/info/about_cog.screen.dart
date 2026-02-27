import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GreenSquareAboutCogScreen extends StatelessWidget {
  const GreenSquareAboutCogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GreenSquareInfoPage(
      title: '콕(cog) 에 관하여',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: getImageLink(
                bucket.asset,
                asset.cogInfo,
                folderPath: assetFolderPath[asset.cogInfo],
              ),
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      '콕(Cog) 이란?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '일상에서 할 수 있는 친환경 활동 인증을\nCog(콕)하기 라고 합니다.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '일회용 비닐봉지 대신 장바구니를,\n탄소 배출량을 줄이기 위한 대중교통 이용 등\nCog(콕)인증 활동으로 다함께 환경을 지켜보아요.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 1,
                      width: 100,
                      color: theme.dividerColor,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '우리가 함께 한 친환경 활동 인증 횟수',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF355149),
                      child: Text(
                        '106,646 회',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '그린스퀘어가 제공한 마일리지',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF355149),
                      child: Text(
                        '46,376,200 M',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
