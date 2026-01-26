import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:flutter/material.dart';

class CodegreenMeetSection extends StatelessWidget {
  const CodegreenMeetSection({
    super.key,
    this.onTapVisit,
  });

  final VoidCallback? onTapVisit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 600;

        final imageUrl = isSmall
            ? getImageLink(
                bucket.asset,
                asset.squareMobile,
                folderPath: assetFolderPath[asset.squareMobile],
              )
            : getImageLink(
                bucket.asset,
                asset.squareWindow,
                folderPath: assetFolderPath[asset.squareWindow],
              );

        // Responsive font sizes
        double headlineFontSize;
        double bodyFontSize;
        if (width < 400) {
          headlineFontSize = 16;
          bodyFontSize = 12;
        } else if (width < 600) {
          headlineFontSize = 20;
          bodyFontSize = 13.5;
        } else if (width < 900) {
          headlineFontSize = 24;
          bodyFontSize = 15;
        } else {
          headlineFontSize = 28;
          bodyFontSize = 16;
        }

        return SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Text(
                'Meet Codegreen & Square',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: headlineFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '그린스퀘어는 친환경의 모든 것을 편리하게 즐길 수 있는 플랫폼입니다.\n코드그린 가방에 있는 QR을 통해 언제 어디서나 그린스퀘어에 입장하고\n일상 속 친환경 활동 인증 보상을 받으세요',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onTapVisit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  '방문하기',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
