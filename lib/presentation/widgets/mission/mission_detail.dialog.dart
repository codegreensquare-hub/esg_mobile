import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class MissionDetailDialog extends StatelessWidget {
  final MissionRow mission;

  const MissionDetailDialog({
    super.key,
    required this.mission,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        mission.thumbnailBucket != null && mission.thumbnailFilename != null
        ? getImageLink(
            mission.thumbnailBucket!,
            mission.thumbnailFilename!,
            folderPath: mission.thumbnailFolderPath,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'mission_title_${mission.id}',
          child: Text(
            mission.title ?? 'No Title',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Image with Hero - square, max 200x200
            if (imageUrl != null)
              Hero(
                tag: 'mission_image_${mission.id}',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, size: 48),
                  ),
                ),
              ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with Hero
                    const SizedBox(height: 16),
                    // Description with Hero
                    Hero(
                      tag: 'mission_text_${mission.id}',
                      child: Text(
                        mission.text ?? 'No Description',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Additional details
                    if (mission.taskExplanation != null) ...[
                      Text(
                        'Explanation',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mission.taskExplanation!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (mission.awardPoints > 0) ...[
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '${mission.awardPoints} Points',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Dates
                    if (mission.startActiveDate != null ||
                        mission.lastActiveDate != null) ...[
                      Text(
                        'Duration',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${mission.startActiveDate ?? 'N/A'} - ${mission.lastActiveDate ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Participate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement participation logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Participation feature coming soon!',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Participate in Mission'),
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
