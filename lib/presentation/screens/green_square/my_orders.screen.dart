import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/green_square/add_product_review.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/order_card.dart';

enum _OrderTab { all, waitingPayment, forDelivery, received, cancelled }

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<OrderEntry>> _future;
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

  String _getOrderItemStatus(OrderItemEntry entry) {
    final item = entry.item;
    if (item.cancelledAt != null) return '취소됨';
    if (item.receivedDeliveryAt != null) return '수령완료';
    if (item.sentForDeliveryAt != null) return '배송중';
    if (item.preparingForDeliveryAt != null) return '배송준비완료';
    return '배송준비';
  }

  List<OrderEntry> _filterOrders(List<OrderEntry> orders, _OrderTab tab) {
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

  Future<List<OrderEntry>> _fetchOrders() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      return const <OrderEntry>[];
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

          return OrderEntry(
            order: order,
            payment: payment,
            shippingAddress: null,
            items: const <OrderItemEntry>[],
          );
        })
        .toList(growable: false);

    final orderIds = baseOrders
        .map((e) => e.order.id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

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

          return OrderItemEntry(
            item: item,
            product: product,
            company: company,
            hasReview: false,
          );
        })
        .where((e) => (e.item.order ?? '').trim().isNotEmpty)
        .fold(<String, List<OrderItemEntry>>{}, (acc, e) {
          final orderId = (e.item.order ?? '').trim();
          (acc[orderId] ??= <OrderItemEntry>[]).add(e);
          return acc;
        });

    final productIds = itemsByOrderId.values
        .expand((list) => list)
        .map((e) => (e.product?.id ?? '').trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    var itemsByOrderIdWithReview = itemsByOrderId.map(
      (orderId, items) => MapEntry(
        orderId,
        items
            .map(
              (e) => OrderItemEntry(
                item: e.item,
                product: e.product,
                company: e.company,
                hasReview: false,
                reviewImages: <ProductReviewImageRow>[],
              ),
            )
            .toList(),
      ),
    );
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

      final reviewIds = allReviews.map((r) => r.id).toList();
      Map<String, List<ProductReviewImageRow>> imagesByReviewId = {};
      if (reviewIds.isNotEmpty) {
        final imagesResponse = await client
            .from(ProductReviewImageTable().tableName)
            .select()
            .inFilter(ProductReviewImageRow.reviewField, reviewIds);

        final allImages = imagesResponse
            .whereType<Map<String, dynamic>>()
            .map(ProductReviewImageRow.fromJson)
            .toList();

        imagesByReviewId = allImages.fold(
          <String, List<ProductReviewImageRow>>{},
          (acc, img) {
            (acc[img.review!] ??= []).add(img);
            return acc;
          },
        );
      }

      itemsByOrderIdWithReview = itemsByOrderId.map((orderId, items) {
        return MapEntry(
          orderId,
          items.map(
            (e) {
              ProductReviewRow? review;
              for (final r in allReviews) {
                if (r.product == e.product?.id && r.order == e.item.order) {
                  review = r;
                  break;
                }
              }
              final hasReview = review != null;
              final reviewImages = review != null
                  ? imagesByReviewId[review.id] ?? <ProductReviewImageRow>[]
                  : <ProductReviewImageRow>[];
              return OrderItemEntry(
                item: e.item,
                product: e.product,
                company: e.company,
                hasReview: hasReview,
                review: review,
                reviewImages: reviewImages,
              );
            },
          ).toList(),
        );
      });
    }

    final result = baseOrders
        .map((entry) {
          final shippingAddressId = entry.order.shippingAddress?.trim();

          return OrderEntry(
            order: entry.order,
            payment: entry.payment,
            shippingAddress: shippingAddressId == null
                ? null
                : addressesById[shippingAddressId],
            items:
                itemsByOrderIdWithReview[entry.order.id] ??
                const <OrderItemEntry>[],
          );
        })
        .toList(growable: false);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
      body: FutureBuilder<List<OrderEntry>>(
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

          final items = snapshot.data ?? const <OrderEntry>[];
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
              return OrderCard(
                entry: entry,
                onReviewPressed: (item, product) async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddProductReviewScreen(
                        orderItem: item,
                        product: product,
                      ),
                    ),
                  );
                  setState(() {
                    _future = _fetchOrders();
                  });
                },
                onCancelPressed: (entry) async {
                  final currentContext = context;
                  final confirmed = await showDialog<bool>(
                    context: currentContext,
                    builder: (context) => AlertDialog(
                      title: const Text('주문 취소'),
                      content: const Text('정말로 이 주문을 취소하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('아니오'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('예'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      final client = Supabase.instance.client;

                      await client
                          .from('order')
                          .delete()
                          .eq('id', entry.order.id);

                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        const SnackBar(content: Text('주문이 취소되었습니다.')),
                      );
                      setState(() {
                        _future = _fetchOrders();
                      });
                    } catch (e) {
                      debugPrint('Error cancelling order: $e');
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        const SnackBar(content: Text('주문 취소 중 오류가 발생했습니다.')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
