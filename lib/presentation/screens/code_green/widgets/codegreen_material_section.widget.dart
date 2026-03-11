import 'package:esg_mobile/core/constants/asset.dart' as asset_constants;
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/constants/frame_width.dart';
import 'package:esg_mobile/core/theme/util.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/presentation/widgets/home/material_card.widget.dart';
import 'package:flutter/material.dart';

class CodegreenMaterialSection extends StatelessWidget {
  const CodegreenMaterialSection({
    this.onTapNature,
    this.onTapVegan,
    this.onTapBiodegradable,
    super.key,
  });

  final VoidCallback? onTapNature;
  final VoidCallback? onTapVegan;
  final VoidCallback? onTapBiodegradable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: frameWidth),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text(
              'Codegreen Material',
              textAlign: TextAlign.center,
              style: createTextTheme(context).headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Text(
                '코드그린은 조금이라도 더 나은 친환경 소재를 위해 끊임없이 찾고, 연구합니다.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final columns = switch (width) {
                  >= 900 => 3,
                  >= 600 => 2,
                  _ => 1,
                };

                const spacing = 16.0;
                final totalSpacing = (columns - 1) * spacing;
                final itemWidth = (width - totalSpacing) / columns;

                final items = [
                  (
                    getImageLink(
                      bucket.asset,
                      asset_constants.asset.materialGrid1,
                      folderPath: asset_constants
                          .assetFolderPath[asset_constants.asset.materialGrid1],
                    ),
                    '천연',
                    'nature-oriented',
                    '가장 자연에 가까운 제품',
                    '천연 제품 보러가기',
                    onTapNature,
                  ),
                  (
                    getImageLink(
                      bucket.asset,
                      asset_constants.asset.materialGrid2,
                      folderPath: asset_constants
                          .assetFolderPath[asset_constants.asset.materialGrid2],
                    ),
                    '비건',
                    'Vegan',
                    '동물성 원부자재가 없는, 모두를 생각한 제품',
                    '비건 제품 보러가기',
                    onTapVegan,
                  ),
                  (
                    getImageLink(
                      bucket.asset,
                      asset_constants.asset.materialGrid3,
                      folderPath: asset_constants
                          .assetFolderPath[asset_constants.asset.materialGrid3],
                    ),
                    '생분해',
                    'biodegradable',
                    '다시 자연으로 돌아가는 제품',
                    '생분해 제품 보러가기',
                    onTapBiodegradable,
                  ),
                ];

                return Wrap(
                  spacing: spacing,
                  runSpacing: 16,
                  children: items
                      .map(
                        (item) => SizedBox(
                          width: itemWidth,
                          child: MaterialCard(
                            imagePath: item.$1,
                            koreanTitle: item.$2,
                            englishTitle: item.$3,
                            description: item.$4,
                            buttonText: item.$5,
                            onButtonPressed: item.$6,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
