import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late final Future<List<_OrderEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchOrders();
  }

  Future<List<_OrderEntry>> _fetchOrders() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      return const <_OrderEntry>[];
    }

    final response = await Supabase.instance.client
        .from(OrderTable().tableName)
        .select('*, payment:payment(*)')
        .eq(OrderRow.orderByField, userId)
        .order(OrderRow.createdAtField, ascending: false);

    return response
        .whereType<Map<String, dynamic>>()
        .map((row) {
          final order = OrderRow.fromJson(row);
          final paymentData = row['payment'];
          final payment = paymentData is Map<String, dynamic>
              ? PaymentRow.fromJson(paymentData)
              : null;
          return _OrderEntry(order: order, payment: payment);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 내역'),
      ),
      body: FutureBuilder<List<_OrderEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LinearProgressIndicator();
          }

          final items = snapshot.data ?? const <_OrderEntry>[];

          if (items.isEmpty) {
            return Center(
              child: Text(
                '주문 내역이 없습니다.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = items[index];
              final paidAt = entry.payment?.paidAt;
              final statusText = paidAt == null ? '결제 대기' : '결제 완료';
              final statusColor = paidAt == null
                  ? cs.onSurfaceVariant
                  : cs.primary;
              final createdText = entry.order.createdAt
                  .toLocal()
                  .toString()
                  .split('.')
                  .first;

              return Card(
                child: ListTile(
                  title: Text(
                    '주문',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    createdText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: Text(
                    statusText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
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
  });

  final OrderRow order;
  final PaymentRow? payment;
}
