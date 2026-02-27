import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:esg_mobile/presentation/widgets/green_square/underlined_title.dart';
import 'package:esg_mobile/presentation/widgets/logo/green_square.logo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GreenSquareBrandStoryScreen extends StatelessWidget {
  const GreenSquareBrandStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GreenSquareInfoPage(
      title: '브랜드 스토리',
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        primary: false,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 42),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '일상 속 친환경이 즐거워지는 공간,',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GreenSquareLogo(
                  height: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '친환경 생활은 귀찮고 어렵다고요?',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '친환경 정보는 정말 여기저기 흩어져 있고,',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '확인하고 따져봐야 하나요?',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '쉽게 찾고, 쉽게 하고, 쉽게 선물도 받아 가세요!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: getImageLink(
                    bucket.asset,
                    asset.story1,
                    folderPath: assetFolderPath[asset.story1],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: UnderlinedTitle(
                '선물이 되어 돌아오는 나의 친환경 하루',
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '아무도 안 알아주고 힘 빠지는 친환경 생활은 이제 끝! 이 곳에서는 바로 할 수 있는 간단한 친환경 활동이 마일리지가 됩니다. 마일리지와 함께 친환경 소비를 더욱 즐겁게 해 보세요.',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: getImageLink(
                    bucket.asset,
                    asset.story2,
                    folderPath: assetFolderPath[asset.story2],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: UnderlinedTitle(
                '재밌는 잡지처럼 읽을 수 있어요',
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '환경 얘기는 재미없고 지루하다는 편견은 넣어두세요. 일상에서 환경을 지키는 가벼운 방법들부터 다양한 친환경 공간과 브랜드, 기업의 이야기까지! 모두 한 곳에 모아 재밌는 컨텐츠로 만들었습니다.',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: getImageLink(
                    bucket.asset,
                    asset.story3,
                    folderPath: assetFolderPath[asset.story3],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: UnderlinedTitle(
                '나의 소비는 곧 가치로 이어집니다.',
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '일일이 찾고, 파악하고 따지느라 힘드셨죠? 예쁘고 편한데 환경까지 생각하는 아이템들, 게다가 가격도 착하대요! 내가 먼저 쓰고 싶은 생활 필수 아이템들만 골라서 모았어요.',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 42),
            ClipRRect(
              child: CachedNetworkImage(
                imageUrl: getImageLink(
                  bucket.asset,
                  asset.story4,
                  folderPath: assetFolderPath[asset.story4],
                ),
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
