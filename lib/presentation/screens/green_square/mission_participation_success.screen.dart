import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/mission.dart';
import 'package:esg_mobile/data/models/supabase/tables/mission_photo_animation_completion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';

class MissionParticipationSuccessScreen extends StatelessWidget {
  const MissionParticipationSuccessScreen({
    super.key,
    required this.mission,
    required this.completionPhotos,
  });

  final MissionRow mission;
  final List<MissionPhotoAnimationCompletionRow> completionPhotos;

  Future<void> _shareToInstagram(BuildContext context) async {
    String? imageUrl;
    if (completionPhotos.isNotEmpty) {
      final photo = completionPhotos.first;
      imageUrl = getImageLink(
        photo.bucket,
        photo.fileName,
        folderPath: photo.folderPath,
      );
    } else if (mission.thumbnailBucket != null &&
        mission.thumbnailFilename != null) {
      imageUrl = getImageLink(
        mission.thumbnailBucket!,
        mission.thumbnailFilename!,
        folderPath: mission.thumbnailFolderPath,
      );
    }

    if (imageUrl == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유할 이미지가 없습니다.')),
        );
      }
      return;
    }

    try {
      final file = await DefaultCacheManager().getSingleFile(imageUrl);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/jpeg')],
          text: '${mission.title ?? '친환경 미션'}에 참여하여 탄소 배출량 ${mission.carbonEmissionsReductionPerParticipationG.toStringAsFixed(1)}g을 줄였어요!\n\n#그린스퀘어 #친환경 #탄소절감 #ESG #지구지킴이 #녹색생활',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유 중 문제가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduction = mission.carbonEmissionsReductionPerParticipationG
        .toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '친환경 미션 참여 완료',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '마일리지는 인증 사진 심사를 거친 후 적립됩니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                width: double.infinity,
                child: completionPhotos.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.emoji_nature, size: 48),
                        ),
                      )
                    : PageView(
                        children: completionPhotos.map((photo) {
                          final url = getImageLink(
                            photo.bucket,
                            photo.fileName,
                            folderPath: photo.folderPath,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade200,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 32),
              Text(
                '방금, ${mission.title ?? '이 미션'}으로',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '나의 하루 평균 탄소 배출량의',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$reduction g 을 줄였어요!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => _shareToInstagram(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('인스타그램으로 친환경 활동 인증하기'),
              ),
              const SizedBox(height: 24),
              Text(
                '미션 참여를 통해 그린스퀘어 몰 즉시 할인이 적용되었습니다.\n인증하신 사진이 승인되면 카카오톡으로 알려드립니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('친환경 상품 할인 받으러 가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
