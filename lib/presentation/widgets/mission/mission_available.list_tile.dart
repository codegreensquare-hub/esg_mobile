import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/services/database/mission_event_tracking.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';

class MissionAvailableListTile extends StatefulWidget {
  const MissionAvailableListTile({
    super.key,
    required this.mission,
    this.onTap,
  });

  final MissionRow mission;
  final void Function(MissionRow mission)? onTap;

  @override
  State<MissionAvailableListTile> createState() =>
      _MissionAvailableListTileState();
}

class _MissionAvailableListTileState extends State<MissionAvailableListTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        MissionEventTrackingService.instance.logImpression(
          missionId: widget.mission.id,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        widget.mission.thumbnailBucket != null &&
            widget.mission.thumbnailFilename != null
        ? getImageLink(
            widget.mission.thumbnailBucket!,
            widget.mission.thumbnailFilename!,
            folderPath: widget.mission.thumbnailFolderPath,
          )
        : null;

    return GestureDetector(
      onTap: widget.onTap != null
          ? () {
              unawaited(
                MissionEventTrackingService.instance.logClick(
                  missionId: widget.mission.id,
                ),
              );
              widget.onTap?.call(widget.mission);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (imageUrl != null)
              Hero(
                tag: 'green-square-mission-image-${widget.mission.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'green-square-mission-title-${widget.mission.id}',
                    child: Text(
                      widget.mission.title ?? 'No Title',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Hero(
                    tag: 'green-square-mission-text-${widget.mission.id}',
                    child: Text(
                      widget.mission.text ?? 'No Description',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.mission.awardPoints} points',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
