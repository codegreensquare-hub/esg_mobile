import 'package:flutter/material.dart';

import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/green_square/order_item_inquiry.screen.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.entry,
    required this.onReviewPressed,
  });

  final OrderEntry entry;
  final Future<void> Function(OrderItemRow item, ProductRow? product)
  onReviewPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final payment = entry.payment;
    String statusText;
    Color statusColor;
    Color statusBackground;
    if (payment == null) {
      statusText = '결제 대기';
      statusColor = cs.onSurfaceVariant;
      statusBackground = cs.surfaceContainerHighest;
    } else if (payment.cancellationId != null) {
      statusText = '결제 취소';
      statusColor = cs.onErrorContainer;
      statusBackground = cs.errorContainer;
    } else if (payment.paidAt != null) {
      statusText = '결제 완료';
      statusColor = cs.onPrimaryContainer;
      statusBackground = cs.primaryContainer;
    } else {
      statusText = '결제 대기';
      statusColor = cs.onSurfaceVariant;
      statusBackground = cs.surfaceContainerHighest;
    }
    final createdText = entry.order.createdAt
        .toLocal()
        .toString()
        .split('.')
        .first;

    final shipping = entry.shippingAddress;
    final recipient = (shipping?.recipientName ?? shipping?.name)?.trim() ?? '';
    final phone = shipping?.phoneNumber?.trim() ?? '';
    final addressLine =
        <String?>[
              shipping?.address,
              shipping?.detailedAddress,
            ]
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .join(' ');

    final companyGroups = entry.items.fold(
      <String, List<OrderItemEntry>>{},
      (acc, e) {
        final companyName = e.company?.name?.trim();
        final key = (companyName ?? '').isEmpty ? '기타' : companyName!;
        (acc[key] ??= <OrderItemEntry>[]).add(e);
        return acc;
      },
    );

    final totalItemCount = entry.items
        .map((e) => (e.item.quantity ?? 0))
        .fold<double>(0, (sum, q) => sum + q);
    final totalItemCountText = totalItemCount % 1 == 0
        ? '${totalItemCount.toInt()}'
        : totalItemCount.toString();

    String getOrderStatus(List<OrderItemEntry> entries) {
      if (entries.isEmpty) return '-';
      final statuses = entries.map((e) {
        final item = e.item;
        if (item.cancelledAt != null) return '취소됨';
        if (item.receivedDeliveryAt != null) return '수령완료';
        if (item.sentForDeliveryAt != null) return '배송중';
        if (item.preparingForDeliveryAt != null) return '배송준비완료';
        return '배송준비';
      }).toSet();
      return statuses.length == 1 ? statuses.first : '혼합';
    }

    final deliveryStatus = getOrderStatus(entry.items);

    final totalItemPrice = entry.items.fold<double>(
      0,
      (sum, e) => sum + ((e.item.price ?? 0) * (e.item.quantity ?? 0)),
    );
    final totalAmount = totalItemPrice - (entry.order.awardPointsUsed ?? 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '주문',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        entry.order.id.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    createdText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '배송: $deliveryStatus',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '총 $totalItemCountText개',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if ((entry.order.awardPointsUsed ?? 0) > 0) ...[
              const SizedBox(height: 4),
              Text(
                '사용 포인트: ${entry.order.awardPointsUsed!.toInt()}P',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '결제 금액: ${totalItemPrice.toInt()}원',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '총 금액: ${totalItemPrice.toInt()}원 - ${entry.order.awardPointsUsed?.toInt() ?? 0}원 = ${totalAmount.toInt()}원',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),

            // add computation here
            // Total Amount: sum of (item.price * item.quantity)
            // minus award points used
            const SizedBox(height: 10),
            Text(
              '배송지',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipient.isEmpty
                        ? '배송지 정보 없음'
                        : [
                            recipient,
                            if (phone.isNotEmpty) phone,
                          ].join(' · '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (addressLine.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      addressLine,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: cs.outlineVariant),
            const SizedBox(height: 12),
            if (entry.items.isEmpty)
              Text(
                '상품 정보가 없습니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            else
              ...companyGroups.entries.expand((companyEntry) {
                final company = companyEntry.key;
                final companyItems = companyEntry.value;

                return [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          company,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${companyItems.length}개',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...companyItems.map((e) {
                    final productTitle =
                        (e.product?.title ?? e.product?.name)?.trim() ?? '';
                    final titleText = productTitle.isEmpty
                        ? '상품 정보 없음'
                        : productTitle;
                    final quantity = e.item.quantity ?? 0;
                    final quantityText = quantity % 1 == 0
                        ? '${quantity.toInt()}'
                        : '$quantity';

                    final product = e.product;
                    final imageUrl =
                        product?.mainImageBucket != null &&
                            product?.mainImageFileName != null
                        ? getImageLink(
                            product!.mainImageBucket!,
                            product.mainImageFileName!,
                            folderPath: product.mainImageFolderPath,
                          )
                        : null;

                    String _getOrderItemStatus(OrderItemEntry entry) {
                      final item = entry.item;
                      if (item.cancelledAt != null) return '취소됨';
                      if (item.receivedDeliveryAt != null) return '수령완료';
                      if (item.sentForDeliveryAt != null) return '배송중';
                      if (item.preparingForDeliveryAt != null) return '배송준비완료';
                      return '배송준비';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OrderItemInquiryScreen(
                                orderItem: e.item,
                                product: e.product,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: imageUrl != null
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    color: cs
                                                        .surfaceContainerHighest,
                                                    child: Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              color: cs.surfaceContainerHighest,
                                              child: Icon(
                                                Icons.image_outlined,
                                                color: cs.onSurfaceVariant,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titleText,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '수량: $quantityText',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '가격: ${e.item.price?.toInt() ?? 0}원',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(
                                        999,
                                      ),
                                    ),
                                    child: Text(
                                      _getOrderItemStatus(e),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_getOrderItemStatus(e) == '수령완료') ...[
                                if (e.hasReview) ...[
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            index < (e.review!.stars.toInt())
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.yellow[600],
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          e.review!.review ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (e.reviewImages.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: e.reviewImages.take(3).map((
                                        img,
                                      ) {
                                        final imageUrl = getImageLink(
                                          img.bucket!,
                                          img.fileName!,
                                          folderPath: img.folderPath,
                                        );
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      color: cs
                                                          .surfaceContainerHighest,
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported_outlined,
                                                        size: 12,
                                                        color:
                                                            cs.onSurfaceVariant,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ] else ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await onReviewPressed(
                                          e.item,
                                          e.product,
                                        );
                                      },
                                      child: const Text('리뷰 작성'),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                ];
              }),
          ],
        ),
      ),
    );
  }
}

class OrderEntry {
  const OrderEntry({
    required this.order,
    required this.payment,
    required this.shippingAddress,
    required this.items,
  });

  final OrderRow order;
  final PaymentRow? payment;
  final UserShippingAddressRow? shippingAddress;
  final List<OrderItemEntry> items;
}

class OrderItemEntry {
  const OrderItemEntry({
    required this.item,
    required this.product,
    required this.company,
    required this.hasReview,
    this.review,
    this.reviewImages = const [],
    this.price,
  });

  final OrderItemRow item;
  final ProductRow? product;
  final CompanyRow? company;
  final bool hasReview;
  final ProductReviewRow? review;
  final List<ProductReviewImageRow> reviewImages;
  final double? price;
}
