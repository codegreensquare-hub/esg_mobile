import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/green_square/add_product_review.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/order_item_inquiry.screen.dart';

enum _OrderTab { all, waitingPayment, forDelivery, received, cancelled }

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final Future<List<_OrderEntry>> _future;
  late final TabController _tabController;

  static const _tabs = [
    Tab(text: '전체'),
    Tab(text: '결제 대기'),
    Tab(text: '배송중'),
    Tab(text: '수령완료'),
    Tab(text: '취소됨'),
  ];

  @override
  void initState() {
    super.initState();
    _future = _fetchOrders();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getOrderItemStatus(_OrderItemEntry entry) {
    final item = entry.item;
    if (item.cancelledAt != null) return '취소됨';
    if (item.receivedDeliveryAt != null) return '수령완료';
    if (item.sentForDeliveryAt != null) return '배송중';
    if (item.preparingForDeliveryAt != null) return '배송준비완료';
    return '배송준비';
  }

  List<_OrderEntry> _filterOrders(List<_OrderEntry> orders, _OrderTab tab) {
    switch (tab) {
      case _OrderTab.all:
        return orders;
      case _OrderTab.waitingPayment:
        return orders.where((e) {
          final payment = e.payment;
          return payment == null ||
              (payment.paidAt == null && payment.cancellationId == null);
        }).toList();
      case _OrderTab.forDelivery:
        return orders.where((e) {
          if (e.payment?.paidAt == null) return false;
          final statuses = e.items.map(_getOrderItemStatus).toSet();
          return !statuses.contains('수령완료') &&
              !statuses.contains('취소됨') &&
              statuses.isNotEmpty;
        }).toList();
      case _OrderTab.received:
        return orders
            .where(
              (e) =>
                  e.items.isNotEmpty &&
                  e.items.every((item) => item.item.receivedDeliveryAt != null),
            )
            .toList();
      case _OrderTab.cancelled:
        return orders
            .where(
              (e) =>
                  e.items.isNotEmpty &&
                  e.items.every((item) => item.item.cancelledAt != null),
            )
            .toList();
    }
  }

  Future<List<_OrderEntry>> _fetchOrders() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      return const <_OrderEntry>[];
    }

    final client = Supabase.instance.client;

    final response = await client
        .from(OrderTable().tableName)
        .select('*, payment!order_payment_fkey(*)')
        .eq(OrderRow.orderByField, userId)
        .order(OrderRow.createdAtField, ascending: false);

    final baseOrders = response
        .whereType<Map<String, dynamic>>()
        .map((row) {
          final order = OrderRow.fromJson(row);
          final paymentData = row['payment'];
          final payment = paymentData is Map<String, dynamic>
              ? PaymentRow.fromJson(paymentData)
              : null;

          return _OrderEntry(
            order: order,
            payment: payment,
            shippingAddress: null,
            items: const <_OrderItemEntry>[],
          );
        })
        .toList(growable: false);

    final orderIds = baseOrders
        .map((e) => e.order.id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (orderIds.isEmpty) {
      return baseOrders;
    }

    final shippingAddressIds = baseOrders
        .map((e) => e.order.shippingAddress?.trim())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final addressesById = shippingAddressIds.isEmpty
        ? const <String, UserShippingAddressRow>{}
        : (await client
                  .from(UserShippingAddressTable().tableName)
                  .select()
                  .inFilter(UserShippingAddressRow.idField, shippingAddressIds))
              .whereType<Map<String, dynamic>>()
              .map(UserShippingAddressRow.fromJson)
              .fold(<String, UserShippingAddressRow>{}, (acc, row) {
                acc[row.id] = row;
                return acc;
              });

    final orderItemsResponse = await client
        .from(OrderItemTable().tableName)
        .select('*, product:product(*, company:company(*))');

    final filteredOrderItems = orderItemsResponse
        .whereType<Map<String, dynamic>>()
        .where((row) => orderIds.contains(row[OrderItemRow.orderField]))
        .toList();

    final itemsByOrderId = filteredOrderItems
        .map((row) {
          final item = OrderItemRow.fromJson(row);
          final productData = row['product'];
          final product = productData is Map<String, dynamic>
              ? ProductRow.fromJson(productData)
              : null;
          final companyData = productData is Map<String, dynamic>
              ? productData['company']
              : null;
          final company = companyData is Map<String, dynamic>
              ? CompanyRow.fromJson(companyData)
              : null;

          return _OrderItemEntry(
            item: item,
            product: product,
            company: company,
            hasReview: false,
          );
        })
        .where((e) => (e.item.order ?? '').trim().isNotEmpty)
        .fold(<String, List<_OrderItemEntry>>{}, (acc, e) {
          final orderId = (e.item.order ?? '').trim();
          (acc[orderId] ??= <_OrderItemEntry>[]).add(e);
          return acc;
        });

    final productIds = itemsByOrderId.values
        .expand((list) => list)
        .map((e) => (e.product?.id ?? '').trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final orderIdsForReview = itemsByOrderId.keys.toList();

    Set<String> reviewedKeys = {};
    if (productIds.isNotEmpty) {
      final reviewsResponse = await client
          .from(ProductReviewTable().tableName)
          .select()
          .eq(ProductReviewRow.createdByField, userId)
          .inFilter(ProductReviewRow.productField, productIds);

      final allReviews = reviewsResponse
          .whereType<Map<String, dynamic>>()
          .map(ProductReviewRow.fromJson)
          .toList();

      reviewedKeys = allReviews
          .where((r) => orderIdsForReview.contains(r.order))
          .map((r) => '${r.product}-${r.order}')
          .toSet();
    }

    final itemsByOrderIdWithReview = itemsByOrderId.map((orderId, items) {
      return MapEntry(
        orderId,
        items
            .map(
              (e) => _OrderItemEntry(
                item: e.item,
                product: e.product,
                company: e.company,
                hasReview:
                    e.product != null &&
                    reviewedKeys.contains('${e.product!.id}-${e.item.order}'),
              ),
            )
            .toList(),
      );
    });

    return baseOrders
        .map((entry) {
          final shippingAddressId = entry.order.shippingAddress?.trim();

          return _OrderEntry(
            order: entry.order,
            payment: entry.payment,
            shippingAddress: shippingAddressId == null
                ? null
                : addressesById[shippingAddressId],
            items:
                itemsByOrderIdWithReview[entry.order.id] ??
                const <_OrderItemEntry>[],
          );
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String getOrderStatus(List<_OrderItemEntry> entries) {
      if (entries.isEmpty) return '-';
      final statuses = entries.map(_getOrderItemStatus).toSet();
      return statuses.length == 1 ? statuses.first : '혼합';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 내역'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
        ),
      ),
      body: FutureBuilder<List<_OrderEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LinearProgressIndicator();
          }

          if (snapshot.hasError) {
            debugPrint('Error fetching orders: ${snapshot.error}');
            return Center(
              child: Text(
                '${snapshot.error}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.error,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final items = snapshot.data ?? const <_OrderEntry>[];
          final filteredItems = _filterOrders(
            items,
            _OrderTab.values[_tabController.index],
          );

          if (filteredItems.isEmpty) {
            return Center(
              child: Text(
                '주문 내역이 없습니다.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: filteredItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = filteredItems[index];
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
              final recipient =
                  (shipping?.recipientName ?? shipping?.name)?.trim() ?? '';
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
                <String, List<_OrderItemEntry>>{},
                (acc, e) {
                  final companyName = e.company?.name?.trim();
                  final key = (companyName ?? '').isEmpty ? '기타' : companyName!;
                  (acc[key] ??= <_OrderItemEntry>[]).add(e);
                  return acc;
                },
              );

              final totalItemCount = entry.items
                  .map((e) => (e.item.quantity ?? 0))
                  .fold<double>(0, (sum, q) => sum + q);
              final totalItemCountText = totalItemCount % 1 == 0
                  ? '${totalItemCount.toInt()}'
                  : totalItemCount.toString();
              final deliveryStatus = getOrderStatus(entry.items);

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
                                  (e.product?.title ?? e.product?.name)
                                      ?.trim() ??
                                  '';
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

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderItemInquiryScreen(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                                color: cs
                                                                    .onSurfaceVariant,
                                                              ),
                                                            ),
                                                      )
                                                    : Container(
                                                        color: cs
                                                            .surfaceContainerHighest,
                                                        child: Icon(
                                                          Icons.image_outlined,
                                                          color: cs
                                                              .onSurfaceVariant,
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
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '수량: $quantityText',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: cs
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    cs.surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      999,
                                                    ),
                                              ),
                                              child: Text(
                                                _getOrderItemStatus(e),
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color:
                                                          cs.onSurfaceVariant,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_getOrderItemStatus(e) == '수령완료' &&
                                            !e.hasReview) ...[
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddProductReviewScreen(
                                                          orderItem: e.item,
                                                          product: e.product,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: const Text('리뷰 작성'),
                                            ),
                                          ),
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
            },
          );
        },
      ),
    );
  }
}

class _OrderEntry {
  const _OrderEntry({
    required this.order,
    required this.payment,
    required this.shippingAddress,
    required this.items,
  });

  final OrderRow order;
  final PaymentRow? payment;
  final UserShippingAddressRow? shippingAddress;
  final List<_OrderItemEntry> items;
}

class _OrderItemEntry {
  const _OrderItemEntry({
    required this.item,
    required this.product,
    required this.company,
    required this.hasReview,
  });

  final OrderItemRow item;
  final ProductRow? product;
  final CompanyRow? company;
  final bool hasReview;
}
