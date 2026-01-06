import 'package:flutter/material.dart';

import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/cart_item_with_product.dart';
import 'package:esg_mobile/presentation/screens/green_square/checkout.screen.dart';

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({
    super.key,
    required this.items,
  });

  final List<CartItemWithProduct> items;

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  late List<CartItemWithProduct> _items;
  final Set<String> _busyCartItemIds = <String>{};
  late final Future<Map<String, String>> _colorHexByIdFuture;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    final colorIds = _items
        .map((e) => (e.cartItem.optionColor ?? '').trim())
        .where((e) => e.isNotEmpty && e.length != 6)
        .toSet();
    _colorHexByIdFuture = CartService.instance.fetchColorHexByIds(colorIds);
  }

  double get _totalPoints => _items.fold<double>(
    0,
    (sum, item) => sum + item.totalPrice,
  );

  Future<void> _setQuantity(CartItemWithProduct item, int newQuantity) async {
    final cartItemId = item.cartItem.id;
    if (_busyCartItemIds.contains(cartItemId)) {
      return;
    }

    setState(() => _busyCartItemIds.add(cartItemId));
    try {
      final ok = await CartService.instance.updateQuantity(
        cartItemId: cartItemId,
        quantity: newQuantity.toDouble(),
      );

      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수량 변경에 실패했습니다.')),
        );
        return;
      }

      setState(() {
        _items = _items
            .map(
              (e) => e.cartItem.id == cartItemId
                  ? CartItemWithProduct(
                      cartItem: e.cartItem.copyWith(
                        quantity: newQuantity.toDouble(),
                      ),
                      product: e.product,
                      options: e.options,
                    )
                  : e,
            )
            .toList(growable: false);
      });
    } finally {
      if (mounted) {
        setState(() => _busyCartItemIds.remove(cartItemId));
      }
    }
  }

  Future<void> _removeItem(CartItemWithProduct item) async {
    final cartItemId = item.cartItem.id;
    if (_busyCartItemIds.contains(cartItemId)) {
      return;
    }

    setState(() => _busyCartItemIds.add(cartItemId));
    try {
      final ok = await CartService.instance.removeItem(cartItemId: cartItemId);
      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제에 실패했습니다.')),
        );
        return;
      }

      setState(() {
        _items = _items
            .where((e) => e.cartItem.id != cartItemId)
            .toList(growable: false);
      });
    } finally {
      if (mounted) {
        setState(() => _busyCartItemIds.remove(cartItemId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return FutureBuilder<Map<String, String>>(
      future: _colorHexByIdFuture,
      builder: (context, snapshot) {
        final colorHexById = snapshot.data ?? const <String, String>{};

        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, controller) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '장바구니',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Text(
                            '장바구니가 비어 있습니다.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final imageUrl =
                                item.product.mainImageBucket != null &&
                                    item.product.mainImageFileName != null
                                ? getImageLink(
                                    item.product.mainImageBucket!,
                                    item.product.mainImageFileName!,
                                    folderPath:
                                        item.product.mainImageFolderPath,
                                  )
                                : null;
                            final isBusy = _busyCartItemIds.contains(
                              item.cartItem.id,
                            );
                            final optionColorId =
                                (item.cartItem.optionColor ?? '').trim();
                            final resolvedHex = optionColorId.isEmpty
                                ? ''
                                : (optionColorId.length == 6
                                          ? optionColorId
                                          : (colorHexById[optionColorId] ?? ''))
                                      .trim();

                            final hasOptionColor = optionColorId.isNotEmpty;
                            final colorChip = optionColorId.isEmpty
                                ? const <Widget>[]
                                : <Widget>[
                                    Chip(
                                      avatar: resolvedHex.length == 6
                                          ? CircleAvatar(
                                              backgroundColor: Color(
                                                int.parse(
                                                  'FF$resolvedHex',
                                                  radix: 16,
                                                ),
                                              ),
                                            )
                                          : null,
                                      label: Text(
                                        resolvedHex.length == 6
                                            ? 'Color: #$resolvedHex'
                                            : 'Color: $optionColorId',
                                      ),
                                      backgroundColor: cs
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.6),
                                    ),
                                  ];

                            final optionChips = item.options
                                .where(
                                  (option) =>
                                      (option.option ?? '').isNotEmpty &&
                                      (option.value ?? '').isNotEmpty,
                                )
                                .where(
                                  (option) =>
                                      !hasOptionColor ||
                                      (option.option ?? '').toLowerCase() !=
                                          'color',
                                )
                                .map(
                                  (option) {
                                    final optionName = (option.option ?? '')
                                        .trim();
                                    final optionValue = (option.value ?? '')
                                        .trim();
                                    final isColor =
                                        optionName.toLowerCase() == 'color' &&
                                        optionValue.length == 6;
                                    return Chip(
                                      avatar: isColor
                                          ? CircleAvatar(
                                              backgroundColor: Color(
                                                int.parse(
                                                  'FF$optionValue',
                                                  radix: 16,
                                                ),
                                              ),
                                            )
                                          : null,
                                      label: Text('$optionName: $optionValue'),
                                      backgroundColor: cs
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.6),
                                    );
                                  },
                                )
                                .toList(growable: false);

                            final chips = <Widget>[
                              ...colorChip,
                              ...optionChips,
                            ];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 80,
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
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              color: cs.surfaceContainerHighest,
                                              child: const Icon(
                                                Icons.image,
                                                size: 40,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.title ?? '제품명 없음',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                onPressed: isBusy
                                                    ? null
                                                    : () {
                                                        if (item.quantity <=
                                                            1) {
                                                          _removeItem(item);
                                                          return;
                                                        }
                                                        _setQuantity(
                                                          item,
                                                          item.quantity - 1,
                                                        );
                                                      },
                                                icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                ),
                                              ),
                                              Text(
                                                '${item.quantity}',
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              ),
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                onPressed: isBusy
                                                    ? null
                                                    : () => _setQuantity(
                                                        item,
                                                        item.quantity + 1,
                                                      ),
                                                icon: const Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                onPressed: isBusy
                                                    ? null
                                                    : () => _removeItem(item),
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  color: cs.error,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '단가: ${item.unitPrice.toStringAsFixed(0)} P',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '합계: ${item.totalPrice.toStringAsFixed(0)} P',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          if (chips.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: chips,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (_items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '총 포인트',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '${_totalPoints.toStringAsFixed(0)} P',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final orderId = await navigator.push<String?>(
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(items: _items),
                              ),
                            );

                            if (!mounted) return;

                            if (orderId != null && orderId.isNotEmpty) {
                              setState(() {
                                _items = const <CartItemWithProduct>[];
                              });
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('주문이 완료되었습니다. 주문 ID: $orderId'),
                                ),
                              );
                            }
                          },
                          child: const Text('결제하러 가기'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
