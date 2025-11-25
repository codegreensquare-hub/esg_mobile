import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/mission.dart';
import 'package:esg_mobile/data/models/supabase/tables/mission_photo_animation_completion.dart';
import 'package:flutter/material.dart';

class MissionParticipationSuccessScreen extends StatelessWidget {
  const MissionParticipationSuccessScreen({
    super.key,
    required this.mission,
    required this.completionPhotos,
  });

  final MissionRow mission;
  final List<MissionPhotoAnimationCompletionRow> completionPhotos;

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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('인스타그램 공유 기능은 준비 중입니다.')),
                  );
                },
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
