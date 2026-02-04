import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/user_shipping_address.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/core/utils/product_pricing.dart';
import 'package:esg_mobile/data/entities/cart_item_with_product.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/portone_payment.dart';
import 'package:esg_mobile/presentation/screens/green_square/shipping_addresses.dialog.dart';
import 'package:esg_mobile/presentation/widgets/green_square/shipping_address_form_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.items,
  });

  final List<CartItemWithProduct> items;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoadingAddress = true;
  bool _isSubmitting = false;
  String? _userId;
  String? _selectedAddressId;
  UserShippingAddressRow? _selectedAddress;
  bool _hasShownForm = false;
  double _userAwardPoints = 0.0;
  bool _hasSetDefaultAwardPoints = false;
  final TextEditingController _awardPointsController = TextEditingController();

  double get _totalPoints => widget.items.fold<double>(
    0,
    (sum, item) => sum + item.totalPrice,
  );

  double get _maxUsableAwardPoints => widget.items.fold<double>(0, (sum, item) {
    final baseDiscountRate = item.product.baseDiscountRate ?? 0.0;
    final platformDiscountRate = item.product.platformDiscountRate ?? 0.0;
    final vendorDiscountRate = item.product.vendorDiscountRate ?? 0.0;
    final baseDiscount = (item.unitPrice * baseDiscountRate / 100).floor();
    return sum +
        (baseDiscount +
                (usableAwardPointsAmount(
                      regularPrice: item.unitPrice,
                      baseDiscountRate: baseDiscountRate,
                      platformDiscountRate: platformDiscountRate,
                      vendorDiscountRate: vendorDiscountRate,
                    ) ??
                    0)) *
            item.quantity;
  });

  double get _usedAwardPoints =>
      double.tryParse(_awardPointsController.text) ?? 0;

  double get _chargedAmount => _totalPoints - _usedAwardPoints;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id;
    _loadDefaultAddress();
    _loadUserAwardPoints();
  }

  Future<void> _loadDefaultAddress() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoadingAddress = false);
      return;
    }

    setState(() => _isLoadingAddress = true);

    final service = UserShippingAddressService.instance;
    final defaultId = await service.fetchDefaultAddressId(userId);

    final normalizedDefaultId = (defaultId ?? '').trim();
    if (normalizedDefaultId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _selectedAddressId = null;
        _selectedAddress = null;
        _isLoadingAddress = false;
      });
      return;
    }

    final address = await service.fetchAddressById(
      userId: userId,
      addressId: normalizedDefaultId,
    );

    if (!mounted) return;
    setState(() {
      _selectedAddressId = normalizedDefaultId;
      _selectedAddress = address;
      _isLoadingAddress = false;
    });
  }

  Future<void> _loadUserAwardPoints() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      final pointsRow = await Supabase.instance.client
          .from('award_points')
          .select('points')
          .eq('user', userId)
          .single();

      if (!mounted) return;
      setState(
        () =>
            _userAwardPoints = (pointsRow['points'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      debugPrint('Error loading user award points: $e');
    }
  }

  Future<void> _manageAddresses() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShippingAddressesDialog(userId: userId),
      ),
    );

    await _loadDefaultAddress();
  }

  Future<void> _showAddressForm() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final result = await showModalBottomSheet<ShippingAddressFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ShippingAddressFormSheet(
        initialSetAsDefault: true,
      ),
    );

    if (!mounted || result == null) return;

    final service = UserShippingAddressService.instance;
    final createdAddress = await service.createAddress(
      userId: userId,
      name: result.name,
      recipientName: result.recipientName,
      phoneNumber: result.phoneNumber,
      address: result.address,
      postalCode: result.postalCode,
      detailedAddress: result.detailedAddress,
      requestsForDelivery: result.requestsForDelivery,
      reusableBoxesAreOkay: result.reusableBoxesAreOkay,
    );

    if (createdAddress == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송지 등록에 실패했습니다.')),
      );
      return;
    }

    if (result.setAsDefault) {
      await service.setDefaultAddress(
        userId: userId,
        addressId: createdAddress.id,
      );
    }

    setState(() {
      _selectedAddressId = createdAddress.id;
      _selectedAddress = createdAddress;
    });
  }

  Future<void> _submitOrder() async {
    final addressId = (_selectedAddressId ?? '').trim();
    if (addressId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송지를 선택해주세요.')),
      );
      return;
    }

    final address = _selectedAddress;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송지를 불러오지 못했습니다. 다시 선택해주세요.')),
      );
      return;
    }

    final buyerName = (address.recipientName ?? address.name ?? '').trim();
    final buyerTel = (address.phoneNumber ?? '').trim();
    final buyerEmail = (Supabase.instance.client.auth.currentUser?.email ?? '')
        .trim();
    final buyerAddr =
        '${(address.address ?? '').trim()} ${(address.detailedAddress ?? '').trim()}'
            .trim();
    final buyerPostcode = (address.postalCode ?? '').trim();

    setState(() => _isSubmitting = true);
    try {
      // Create order first
      final orderId = await CartService.instance.checkoutCart(
        shippingAddressId: addressId,
        awardPoints: _usedAwardPoints,
      );

      if ((orderId ?? '').isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주문 생성에 실패했습니다.')),
        );
        return;
      }

      // Create payment record with order_being_paid
      final payment = await CartService.instance.createPayment(
        amount: _chargedAmount,
        status: 'pending',
        orderId: orderId,
      );

      if (payment == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('결제 생성에 실패했습니다. 다시 시도해주세요.')),
        );
        return;
      }

      // Link payment to order
      await Supabase.instance.client
          .from('order')
          .update({OrderRow.paymentField: payment.id})
          .eq(OrderRow.idField, orderId!.trim());

      // Navigate to PortOne payment screen
      final result = await Navigator.of(context).push<Map<String, String>>(
        MaterialPageRoute(
          builder: (context) => PortonePaymentScreen(
            paymentId: payment.id,
            amount: _chargedAmount,
            shippingAddressId: addressId,
            userId: _userId!,
            buyerName: buyerName.isEmpty ? '고객' : buyerName,
            buyerTel: buyerTel,
            buyerEmail: buyerEmail,
            buyerAddr: buyerAddr,
            buyerPostcode: buyerPostcode,
          ),
        ),
      );

      if (!mounted) return;

      if (result != null && result['imp_success'] == 'true') {
        // Update payment status
        await CartService.instance.updatePaymentStatus(
          paymentId: payment.id,
          status: 'paid',
          paidAt: DateTime.now(),
          platformId: result['imp_uid'],
          otherData: result,
        );

        Navigator.of(context).pop(orderId);
      } else {
        // Payment failed or cancelled
        await CartService.instance.updatePaymentStatus(
          paymentId: payment.id,
          status: 'failed',
          otherData: result,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('결제가 취소되었습니다.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('주문 실패: $e')),
      );
      debugPrint('Error submitting order: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _awardPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoadingAddress && _selectedAddress == null && !_hasShownForm) {
      _hasShownForm = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAddressForm());
    }

    // Set default award points value
    if (!_hasSetDefaultAwardPoints && _userAwardPoints > 0) {
      final maxAllowed = _userAwardPoints < _maxUsableAwardPoints
          ? _userAwardPoints
          : _maxUsableAwardPoints;
      if (maxAllowed > 0) {
        _awardPointsController.text = maxAllowed.toStringAsFixed(0);
        _hasSetDefaultAwardPoints = true;
      }
    }

    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문/결제'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '배송지',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _manageAddresses,
                          child: const Text('배송지 변경'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingAddress)
                      const LinearProgressIndicator()
                    else if (_selectedAddress == null)
                      Text(
                        '선택된 배송지가 없습니다. 배송지를 등록하고 기본 배송지로 설정해주세요.',
                        style: theme.textTheme.bodyMedium,
                      )
                    else
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedAddress?.name ?? '배송지',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '받는 사람: ${_selectedAddress?.recipientName ?? ''}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '연락처: ${_selectedAddress?.phoneNumber ?? ''}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    if ((_selectedAddress?.postalCode ?? '')
                                        .trim()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '우편번호: ${_selectedAddress?.postalCode}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Text(
                                      '주소: ${_selectedAddress?.address ?? ''}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    if ((_selectedAddress?.detailedAddress ??
                                            '')
                                        .trim()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '상세 주소: ${_selectedAddress?.detailedAddress}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                    if ((_selectedAddress
                                                ?.requestsForDelivery ??
                                            '')
                                        .trim()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '배송 요청사항: ${_selectedAddress?.requestsForDelivery}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    Text(
                      '주문 상품',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final imageUrl =
                            item.product.mainImageBucket != null &&
                                item.product.mainImageFileName != null
                            ? getImageLink(
                                item.product.mainImageBucket!,
                                item.product.mainImageFileName!,
                                folderPath: item.product.mainImageFolderPath,
                              )
                            : null;
                        final baseDiscountRate =
                            item.product.baseDiscountRate ?? 0.0;
                        final platformDiscountRate =
                            item.product.platformDiscountRate ?? 0.0;
                        final vendorDiscountRate =
                            item.product.vendorDiscountRate ?? 0.0;

                        final baseDiscount =
                            (item.unitPrice * baseDiscountRate / 100).floor();
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
                                                color: theme
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
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
                                        item.product.title ??
                                            item.product.name ??
                                            '제품명 없음',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '수량: ${item.quantity}개',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '합계: ${formatter.format(item.totalPrice.toInt())}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '사용 가능 포인트: ${formatter.format((baseDiscount + (usableAwardPointsAmount(regularPrice: item.unitPrice, baseDiscountRate: baseDiscountRate, platformDiscountRate: platformDiscountRate, vendorDiscountRate: vendorDiscountRate) ?? 0)) * item.quantity)}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          '사용 포인트',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _awardPointsController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              suffixText: 'P',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value) ?? 0;
                              final maxAllowed =
                                  _userAwardPoints < _maxUsableAwardPoints
                                  ? _userAwardPoints
                                  : _maxUsableAwardPoints;
                              final clamped = parsed.clamp(0, maxAllowed);
                              if (parsed != clamped) {
                                _awardPointsController.text = clamped
                                    .toStringAsFixed(0);
                                _awardPointsController
                                    .selection = TextSelection.collapsed(
                                  offset: _awardPointsController.text.length,
                                );
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 포인트',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          formatter.format(_totalPoints.toInt()),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '사용 포인트',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Text(
                          '-${formatter.format(_usedAwardPoints.toInt())}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 금액',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${formatter.format(_chargedAmount.toInt())}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _isSubmitting || _selectedAddress == null
                          ? null
                          : _submitOrder,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('주문 확정'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
