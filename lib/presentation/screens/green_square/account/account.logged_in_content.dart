import 'package:flutter/material.dart';

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
  });

  final String userName;
  final double totalMileage;
  final List<Map<String, dynamic>> activeMissions;
  final List<Map<String, dynamic>> participations;
  final VoidCallback onManageShipping;
  final VoidCallback onOrderLookup;
  final VoidCallback onWishlist;
  final VoidCallback onMyComments;
  final VoidCallback onLikedStories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final mileageText = totalMileage == totalMileage.roundToDouble()
        ? totalMileage.toInt().toString()
        : totalMileage.toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '현재 보유 마일리지',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '$mileageText P',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.local_shipping_outlined,
                  label: '주문배송조회',
                  onTap: onOrderLookup,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.favorite_outline,
                  label: '찜한 상품',
                  onTap: onWishlist,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.comment_outlined,
                  label: '내가 쓴 댓글',
                  onTap: onMyComments,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.thumb_up_outlined,
                  label: '좋아요 한 글',
                  onTap: onLikedStories,
                ),
              ),
            ],
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
              children: activeMissions.map((mission) {
                return Card(
                  // padding: const EdgeInsets.all(16),
                  // decoration: BoxDecoration(
                  //   color: cs.surface,
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission['title'] ?? '미션',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          '+${mission['earned']} P',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                final status = participation['status'] as String;
                final isApproved = status == 'approved';
                final isPending = status == 'pending';
                final photoUrl = participation['photo_url'] as String?;
                final rejectionReason =
                    participation['rejection_reason'] as String?;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: photoUrl != null
                            ? Image.network(
                                photoUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 72,
                                height: 72,
                                color: cs.surfaceTint.withValues(alpha: 0.1),
                                child: const Icon(Icons.photo_outlined),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              participation['mission_title'] ?? '미션',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '참여일: ${DateTime.parse(participation['created_at']).toLocal().toString().split(' ')[0]}',
                              style: theme.textTheme.bodySmall,
                            ),
                            if (!isApproved && rejectionReason != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '사유: $rejectionReason',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? Colors.green.shade100
                              : isPending
                              ? Colors.orange.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isApproved
                              ? '승인됨'
                              : isPending
                              ? '심사 중'
                              : '거부됨',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isApproved
                                ? Colors.green.shade800
                                : isPending
                                ? Colors.orange.shade800
                                : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
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
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
