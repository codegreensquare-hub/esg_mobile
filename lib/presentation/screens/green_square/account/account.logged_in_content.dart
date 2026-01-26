import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esg_mobile/data/entities/active_mission.dart';
import 'package:esg_mobile/data/entities/participation.dart';

class AccountLoggedInContent extends StatelessWidget {
  const AccountLoggedInContent({
    super.key,
    required this.userName,
    required this.totalMileage,
    required this.activeMissions,
    required this.participations,
    required this.onManageShipping,
    required this.onOrderLookup,
    required this.onWishlist,
    required this.onMyComments,
    required this.onLikedStories,
    required this.companyName,
    required this.onSelectCompany,
    required this.onRemoveCompany,
    required this.isEmployee,
    required this.departmentName,
    required this.onSetIsEmployee,
    required this.onSelectDepartment,
    required this.onRemoveDepartment,
  });

  final String userName;
  final double totalMileage;
  final List<ActiveMission> activeMissions;
  final List<Participation> participations;
  final VoidCallback onManageShipping;
  final VoidCallback onOrderLookup;
  final VoidCallback onWishlist;
  final VoidCallback onMyComments;
  final VoidCallback onLikedStories;
  final String? companyName;
  final VoidCallback onSelectCompany;
  final VoidCallback onRemoveCompany;
  final bool? isEmployee;
  final String? departmentName;
  final void Function(bool) onSetIsEmployee;
  final VoidCallback onSelectDepartment;
  final VoidCallback onRemoveDepartment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final mileageText = totalMileage == totalMileage.roundToDouble()
        ? totalMileage.toInt().toString()
        : totalMileage.toStringAsFixed(1);

    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      userName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onManageShipping,
                    icon: const Icon(Icons.location_on_outlined),
                    label: const Text('배송지 관리'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Level 1',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        if (companyName == null) {
                          onSelectCompany();
                        } else {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('회사 변경'),
                              content: const Text('회사를 변경하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('변경'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            onSelectCompany();
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(companyName ?? '회사 없음'),
                    ),
                  ),
                  if (companyName != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('회사 제거'),
                            content: const Text('회사를 제거하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('제거'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          onRemoveCompany();
                        }
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              if (companyName != null) ...[
                const SizedBox(height: 8),
                Text(
                  '관계',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onSetIsEmployee(true),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isEmployee == true
                              ? cs.primaryContainer
                              : null,
                        ),
                        child: const Text('직원'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onSetIsEmployee(false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isEmployee == false
                              ? cs.primaryContainer
                              : null,
                        ),
                        child: const Text('직원 가족'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onSelectDepartment,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(departmentName ?? '부서 선택'),
                      ),
                    ),
                    if (departmentName != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onRemoveDepartment,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onManageShipping,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('배송지 관리'),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(6),

                  border: Border.all(color: cs.outlineVariant, width: 0.5),
                ),

                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '현재 보유 마일리지',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Text(
                    //   '$mileageText P',
                    //   style: theme.textTheme.headlineSmall?.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //     color: cs.primary,
                    //   ),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.network(
                          getImageLink(
                            bucket.asset,
                            asset.cMilage,
                            folderPath: assetFolderPath[asset.cMilage],
                          ),
                          width: 20,
                          height: 20,
                          semanticsLabel: '마일리지',
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mileageText,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: cs.outlineVariant, width: 0.5),
                ),
                padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.local_shipping_outlined,
                        label: '주문배송조회',
                        onTap: onOrderLookup,
                      ),
                    ),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.favorite_outline,
                        label: '찜한 상품',
                        onTap: onWishlist,
                      ),
                    ),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.comment_outlined,
                        label: '내가 쓴 댓글',
                        onTap: onMyComments,
                      ),
                    ),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.thumb_up_outlined,
                        label: '좋아요 한 글',
                        onTap: onLikedStories,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '현재 미션',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (activeMissions.isEmpty)
                const Center(child: Text('현재 진행 중인 미션이 없습니다.'))
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 4 / 3,
                  children: activeMissions.map((mission) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: mission.stampUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: mission.stampUrl!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                  )
                                : SvgPicture.network(
                                    getImageLink(
                                      bucket.asset,
                                      asset.cMilage,
                                      folderPath:
                                          assetFolderPath[asset.cMilage],
                                    ),
                                    width: 40,
                                    height: 40,
                                    semanticsLabel: '미션 스탬프',
                                  ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            mission.title ?? '미션',
                            style: theme.textTheme.titleMedium?.copyWith(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${mission.earned} 회',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
              Text(
                '참여 기록',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (participations.isEmpty)
                const Center(child: Text('참여 기록이 없습니다.'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: participations.length,
                  itemBuilder: (context, index) {
                    final participation = participations[index];
                    final rejectionReason = participation.rejectionReason;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: participation.stampUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: participation.stampUrl!,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const SizedBox(
                                            width: 72,
                                            height: 72,
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            width: 72,
                                            height: 72,
                                            color: cs.surfaceTint.withValues(
                                              alpha: 0.1,
                                            ),
                                            child: const Icon(
                                              Icons.photo_outlined,
                                            ),
                                          ),
                                    )
                                  : Container(
                                      width: 72,
                                      height: 72,
                                      color: cs.surfaceTint.withValues(
                                        alpha: 0.1,
                                      ),
                                      child: const Icon(Icons.photo_outlined),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        participation.missionTitle,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: participation.isApproved
                                            ? Colors.green.shade100
                                            : participation.isPending
                                            ? Colors.orange.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        participation.isApproved
                                            ? '승인됨'
                                            : participation.isPending
                                            ? '심사 중'
                                            : '거부됨',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: participation.isApproved
                                                  ? Colors.green.shade800
                                                  : participation.isPending
                                                  ? Colors.orange.shade800
                                                  : Colors.red.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (participation.photoUrl != null) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: participation.photoUrl!,
                                      height: screenWidth / 2,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  '참여일: ${participation.createdAt.toLocal().toString().split(' ')[0]}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (!participation.isApproved &&
                                    rejectionReason != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '사유: $rejectionReason',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.red.shade700,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
