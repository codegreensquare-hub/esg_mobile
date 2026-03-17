import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/services/database/mission_event_tracking.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/enums/mission_type.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/widgets/general_mission_card.dart';
import 'package:esg_mobile/presentation/widgets/mission/banner_mission_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

enum MissionAvailableTileVariant { list, grid }

class MissionAvailableListTile extends StatefulWidget {
  const MissionAvailableListTile({
    super.key,
    required this.mission,
    this.onTap,
    this.variant = MissionAvailableTileVariant.list,
  });

  final MissionRow mission;
  final void Function(MissionRow mission)? onTap;
  final MissionAvailableTileVariant variant;

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final imageUrl =
        widget.mission.thumbnailBucket != null &&
            widget.mission.thumbnailFilename != null
        ? getImageLink(
            widget.mission.thumbnailBucket!,
            widget.mission.thumbnailFilename!,
            folderPath: widget.mission.thumbnailFolderPath,
          )
        : null;
    final points = widget.mission.awardPoints;
    final isBannerMission = widget.mission.type == MissionType.banner_exposed;

    if (widget.variant == MissionAvailableTileVariant.grid) {
      // Grid cards should look identical for all mission types.
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
        child: _buildGridCard(theme, cs, imageUrl, points),
      );
    }

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
      child: isBannerMission
          ? BannerMissionCard(
              background: _buildBannerBackground(imageUrl),
              child: _buildBannerContent(theme, cs, points),
            )
          : GeneralMissionCard(
              child: Row(
                children: [
                  _buildThumbnail(imageUrl),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextContent(theme, cs, points),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGridCard(
    ThemeData theme,
    ColorScheme cs,
    String? imageUrl,
    int? points,
  ) {
    final formatter = NumberFormat('#,###');
    final formattedPoints = formatter.format(points ?? 0);

    return GeneralMissionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      borderRadius: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.mission.title ?? 'No Title',
            style: (theme.textTheme.titleSmall ?? const TextStyle(fontSize: 14))
                .copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: (theme.textTheme.titleSmall?.fontSize ?? 14) + 1,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.network(
                getImageLink(
                  bucket.asset,
                  asset.cMilage,
                  folderPath: assetFolderPath[asset.cMilage],
                ),
                width: 18,
                height: 18,
                semanticsLabel: '포인트',
              ),
              const SizedBox(width: 6),
              Text(
                formattedPoints,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Hero(
              tag: 'green-square-mission-image-${widget.mission.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildGridImage(imageUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridImage(String? imageUrl) {
    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported),
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported),
    );
  }

  Widget _buildThumbnail(String? imageUrl) {
    if (imageUrl != null) {
      return Hero(
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
      );
    }

    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported),
    );
  }

  Widget _buildTextContent(
    ThemeData theme,
    ColorScheme cs,
    int? points,
  ) {
    final formattedPoints = NumberFormat('#,###').format(points ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Hero(
                tag: 'green-square-mission-title-${widget.mission.id}',
                child: Text(
                  widget.mission.title ?? 'No Title',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.network(
                  getImageLink(
                    bucket.asset,
                    asset.cMilage,
                    folderPath: assetFolderPath[asset.cMilage],
                  ),
                  width: 16,
                  height: 16,
                  semanticsLabel: '포인트',
                ),
                const SizedBox(width: 4),
                Text(
                  formattedPoints,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Hero(
          tag: 'green-square-mission-text-${widget.mission.id}',
          child: Text(
            widget.mission.text ?? 'No Description',
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerBackground(String? imageUrl) {
    if (imageUrl != null) {
      return Hero(
        tag: 'green-square-mission-image-${widget.mission.id}',
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[400],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[400],
            child: const Center(child: Icon(Icons.image_not_supported)),
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[400],
    );
  }

  /// Banner-only content: top-left badge + bottom-left text + bottom-right C circle + points.
  Widget _buildBannerContent(
    ThemeData theme,
    ColorScheme cs,
    int? points,
  ) {
    final badgeText = _bannerBadgeText();
    return Stack(
      children: [
        // Bottom block: title, description, and points row
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'green-square-mission-title-${widget.mission.id}',
                        child: Text(
                          widget.mission.title ?? 'No Title',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Hero(
                        tag: 'green-square-mission-text-${widget.mission.id}',
                        child: Text(
                          widget.mission.text ?? 'No Description',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildBannerPointsIndicator(theme, cs, points),
              ],
            ),
          ),
        ),
        // Top-left pill badge from mission data
        if (badgeText != null && badgeText.isNotEmpty)
          Positioned(
            top: 20,
            left: 20,
            child: _BannerBadge(label: badgeText),
          ),
      ],
    );
  }

  /// C logo (reverse) + points; aligned with title. Reverse icon for visibility on gradient.
  /// Uses local asset to avoid network load and crashes when scrolling.
  Widget _buildBannerPointsIndicator(
    ThemeData theme,
    ColorScheme cs,
    int? points,
  ) {
    final formattedPoints = NumberFormat('#,###').format(points ?? 0);
    final path =
        'assets/${assetFolderPath[asset.cMileageReverse]}/${asset.cMileageReverse}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          path,
          width: 16,
          height: 16,
          semanticsLabel: '포인트',
        ),
        const SizedBox(width: 4),
        Text(
          formattedPoints,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Badge label from mission: participationButtonText, or "기간 한정 미션", or default.
  String? _bannerBadgeText() {
    final custom = widget.mission.participationButtonText?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    final start = widget.mission.startActiveDate;
    final end = widget.mission.lastActiveDate;
    if (start != null && start.isNotEmpty && end != null && end.isNotEmpty) {
      return '기간 한정 미션';
    }
    return '지금 참여 가능해요';
  }
}

/// Pill-shaped badge for banner card (e.g. "지금 참여 가능해요", "기간 한정 미션").
class _BannerBadge extends StatelessWidget {
  const _BannerBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style:
            Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF2D5016),
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5016),
            ),
      ),
    );
  }
}
