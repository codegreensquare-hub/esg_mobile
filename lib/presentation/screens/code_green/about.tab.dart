import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/presentation/widgets/green_square/green_square_statistics_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutTab extends StatefulWidget {
  static const tab = 'about';

  final VoidCallback? onTapCodeGreenProducts;
  final VoidCallback? onTapGreenSquare;

  const AboutTab({
    super.key,
    this.onTapCodeGreenProducts,
    this.onTapGreenSquare,
  });

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main title: About
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Text(
              'About',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tree image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CachedNetworkImage(
              imageUrl: getImageLink(
                bucket.asset,
                asset.tree,
                folderPath: assetFolderPath[asset.tree],
              ),
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

          const SizedBox(height: 80),

          // Section 1: 친환경 소비가 즐겁고 기쁜 곳
          CachedNetworkImage(
            imageUrl: getImageLink(
              bucket.asset,
              asset.about1,
              folderPath: assetFolderPath[asset.about1],
            ),
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '친환경 소비가 즐겁고 기쁜 곳',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '코드그린은 친환경 패션 브랜드가 아닙니다.\n'
                  '모든 사람들의 친환경 소비가 즐겁고 행복하길 바라며\n'
                  '연구하고, 노력하는 곳입니다.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          const SizedBox(height: 64),

          // Section 2: 친환경이지만 예쁘고 좋은 코드 그린
          CachedNetworkImage(
            imageUrl: getImageLink(
              bucket.asset,
              asset.about2,
              folderPath: assetFolderPath[asset.about2],
            ),
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '친환경이지만 예쁘고 좋은 코드 그린',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '환경을 생각하는 마음만큼, 제품의 가치를 생각합니다.\n'
                  '우선 예쁘고 좋아서 마음이 두근거려야, 자연을 위한 마음도 따뜻해질 수 있다 믿습니다.\n'
                  '코드그린의 제품은 훌륭합니다.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          const SizedBox(height: 64),

          // Section 3: 연구하고, 사색하는 친환경 브랜드
          CachedNetworkImage(
            imageUrl: getImageLink(
              bucket.asset,
              asset.about3,
              folderPath: assetFolderPath[asset.about3],
            ),
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '연구하고, 사색하는 친환경 브랜드',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Code Green은 환경에 기여하는 기업들을 연구해오며 만들어진 브랜드입니다.\n'
                  '우리만의 가치관으로 친환경을 추구하고, 연구하며, 노력합니다.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                // Black button: 코드그린 상품 보러가기
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onTapCodeGreenProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      '코드그린 상품 보러가기',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal rule
          const Divider(height: 96, thickness: 1),

          // Section 4: 그린 스퀘어
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/about/squareLogo.360eaffc.svg',
                height: 40,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '코드 그린이 만드는\n'
                  '친환경 소비가 편하고 즐거운 곳,\n'
                  '그린 스퀘어',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  '누구나,\n\n'
                  '친환경 소비를 하고 인증 할 수 있어요.\n'
                  '편하고, 빨라요.\n\n'
                  '마일리지로 친환경 제품/서비스를\n'
                  '싸게 살 수 있어요.\n\n'
                  '산재되어 있고, 찾기 힘든\n'
                  '친환경 제품들과 콘텐츠를 모아 놓았어요.\n'
                  '누리기만 하면 돼요.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                // Black button: 함께하러 가기
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onTapGreenSquare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      '함께하러 가기',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // Section 5: 지금도 그린 스퀘어에서는
          const GreenSquareStatisticsBanner(),

          const SizedBox(height: 80),

          // Section 6: History
          CachedNetworkImage(
            imageUrl: getImageLink(
              bucket.asset,
              asset.about4,
              folderPath: assetFolderPath[asset.about4],
            ),
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'History of\ncode green & square',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  '자연을 좋아합니다. 노르웨이 달스비나에서\n'
                  '물아일체(物我一體)를 느끼기도 했습니다. 날씨 좋은 날,\n'
                  '아름다운 곳에서 사람들이 웃는 것만 봐도 좋습니다.\n\n'
                  '그래서 수익을 창출하는 동시에 환경에\n'
                  '기여하는 기업을 11년간 연구해왔습니다.\n'
                  '2017년부터 2년 동안 노르웨이, 스웨덴,\n'
                  '덴마크, 독일 등 환경 선진국 15개국,\n'
                  '300개의 이상적인 Green Business기업을\n'
                  '직접 만나오며 길을 찾았습니다.\n\n'
                  '2017년 미세플라스틱 파동이 있었고,\n'
                  '2018년 비닐대란을 보았습니다.\n\n'
                  '친환경 소비도 마땅히 즐거워야 하며,\n'
                  '즐겁고 행복해야 변화를 만들 수 있다는\n'
                  '생각을 하게되었습니다.\n\n'
                  '2019년 Code Green이 시작되었고,\n'
                  '2021년 Green Square가 시작됐습니다.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // Code Green and Green Square Logos with buttons in two columns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Code Green Logo Column
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
                        child: SvgPicture.asset(
                          'assets/images/logos/codegreen_logo.svg',
                          width: 168,
                          height: 50,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onTapCodeGreenProducts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            '상품 보러가기',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Green Square Logo Column
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                        child: SvgPicture.asset(
                          'assets/images/logos/greensquare_logo.svg',
                          height: 50,
                          width: 168,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onTapGreenSquare,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            '놀러가기',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
