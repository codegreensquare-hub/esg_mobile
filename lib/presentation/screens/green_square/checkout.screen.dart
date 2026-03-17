import 'package:animated_toggle_switch/animated_toggle_switch.dart';
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
import 'package:esg_mobile/presentation/screens/green_square/my_orders.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/shipping_addresses.dialog.dart';
import 'package:esg_mobile/presentation/widgets/green_square/shipping_address_form_sheet.dart';

/// Shipping fee applied at checkout (KRW).
const int _shippingFee = 2500;

// Checkout UI style (Figma)
const Color _pageBackground = Color(0xFFF5F3F2);
const Color _sectionBackground = Color(0xFFFFFFFF);
const Color _sectionDivider = Color(0xFFE5E5E5);
const Color _inputBorder = Color(0xFFEBEBEB);
const Color _inputLabelColor = Color(0xFF3B3733);
const Color _sectionLabelColor = Color(0xFF747474);
const Color _quantityGray = Color(0xFFAAAAAA);
const Color _purchaseButtonBg = Color(0xFF2F473F);
const Color _mileageOrange = Color(0xFFC88660);
const double _sectionGap = 25;
const String _fontFamily = 'Noto Sans KR';

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
  final FocusNode _awardPointsFocusNode = FocusNode();

  // New UI: orderer info
  final TextEditingController _ordererNameController = TextEditingController();
  final TextEditingController _ordererPhoneController = TextEditingController();
  final TextEditingController _ordererEmailController = TextEditingController();
  bool _useMileage = false;
  int? _selectedPaymentMethod; // 0: 신용/체크카드, 1: 계좌이체, 2: 무통장 입금, 3: 휴대폰 결제
  static const List<String> _paymentMethodLabels = [
    '신용/체크카드',
    '계좌이체',
    '무통장 입금',
    '휴대폰 결제',
  ];

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
                usableAwardPointsAmount(
                  regularPrice: item.unitPrice,
                  baseDiscountRate: baseDiscountRate,
                  platformDiscountRate: platformDiscountRate,
                  vendorDiscountRate: vendorDiscountRate,
                )) *
            item.quantity;
  });

  double get _usedAwardPoints =>
      double.tryParse(_awardPointsController.text) ?? 0;

  double get _defaultAwardPointsToUse =>
      _userAwardPoints < _maxUsableAwardPoints
      ? _userAwardPoints
      : _maxUsableAwardPoints;

  /// Award points actually applied (only when mileage checkbox is on).
  double get _effectiveUsedAwardPoints => _useMileage ? _usedAwardPoints : 0.0;

  double get _chargedAmount =>
      _totalPoints - _effectiveUsedAwardPoints + _shippingFee;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id;
    _ordererEmailController.text =
        Supabase.instance.client.auth.currentUser?.email ?? '';
    _loadDefaultAddress();
    _loadUserAwardPoints();
  }

  void _fillOrdererFromAddress(UserShippingAddressRow address) {
    _ordererNameController.text = (address.recipientName ?? address.name ?? '')
        .trim();
    _ordererPhoneController.text = (address.phoneNumber ?? '').trim();
  }

  void _setAwardPointsInput(double value) {
    final normalized = value.clamp(0.0, _defaultAwardPointsToUse);
    final text = normalized.toStringAsFixed(0);
    _awardPointsController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _handleUseMileageChanged(bool enabled) {
    setState(() {
      _useMileage = enabled;
      if (!enabled) {
        _awardPointsFocusNode.unfocus();
        return;
      }

      final currentValue = double.tryParse(_awardPointsController.text) ?? 0;
      final nextValue = currentValue > 0
          ? currentValue
          : _defaultAwardPointsToUse;
      _setAwardPointsInput(nextValue);
    });

    if (enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _awardPointsFocusNode.requestFocus();
        _awardPointsController.selection = TextSelection.collapsed(
          offset: _awardPointsController.text.length,
        );
      });
    }
  }

  void _handleAwardPointsChanged(String value) {
    final parsed = double.tryParse(value) ?? 0;
    final clamped = parsed.clamp(0.0, _defaultAwardPointsToUse);

    if (parsed != clamped) {
      _setAwardPointsInput(clamped);
    }

    setState(() {});
  }

  void _goToOrdersScreen() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
      (route) => route.isFirst,
    );
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
      if (address != null) _fillOrdererFromAddress(address);
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
      _fillOrdererFromAddress(createdAddress);
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
        awardPoints: _effectiveUsedAwardPoints,
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

        if (!mounted) return;

        _goToOrdersScreen();
      } else {
        // Payment failed or cancelled
        await CartService.instance.updatePaymentStatus(
          paymentId: payment.id,
          status: 'failed',
          otherData: result,
        );

        if (!mounted) return;

        _goToOrdersScreen();
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
    _awardPointsFocusNode.dispose();
    _ordererNameController.dispose();
    _ordererPhoneController.dispose();
    _ordererEmailController.dispose();
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
      final maxAllowed = _defaultAwardPointsToUse;
      if (maxAllowed > 0) {
        _setAwardPointsInput(maxAllowed);
        _hasSetDefaultAwardPoints = true;
      }
    }

    return _buildNewCheckoutUI(context);
  }

  /// Legacy checkout UI – restore by returning this from [build] instead of [_buildNewCheckoutUI].
  // ignore: unused_element
  Widget _buildLegacyCheckoutUI(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###');
    return Scaffold(
      appBar: AppBar(title: const Text('주문/결제')),
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
                                    const SizedBox(height: 8),
                                    Text(
                                      '주소: ${_selectedAddress?.address ?? ''}${(_selectedAddress?.detailedAddress ?? '').trim().isEmpty ? '' : ' ${_selectedAddress!.detailedAddress}'}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
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
                        return ListTile(
                          title: Text(
                            item.product.title ?? item.product.name ?? '제품명 없음',
                          ),
                          subtitle: Text(
                            '수량: ${item.quantity}개 / 합계: ${formatter.format(item.totalPrice.toInt())}',
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('사용 포인트', style: theme.textTheme.titleMedium),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _awardPointsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0',
                          suffixText: 'P',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
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
        ],
      ),
    );
  }

  Widget _buildNewCheckoutUI(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final formatter = NumberFormat('#,###');
    final productTotal = _totalPoints;
    final mileageUsed = _effectiveUsedAwardPoints;
    const couponDiscount = 0.0;
    final totalPayment =
        productTotal - mileageUsed - couponDiscount + _shippingFee;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: _buildGreenSquareSwitchTitle(theme, cs),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 주문자 정보
              _buildSection(
                context,
                label: '주문자 정보',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLabeledField('보내시는 분', _ordererNameController),
                    const SizedBox(height: 12),
                    _buildLabeledField('연락처', _ordererPhoneController),
                    const SizedBox(height: 12),
                    _buildLabeledField('이메일', _ordererEmailController),
                  ],
                ),
              ),
              const SizedBox(height: _sectionGap),

              // 배송지 정보
              _buildSection(
                context,
                label: '배송지 정보',
                child: _isLoadingAddress
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _selectedAddress == null
                    ? Text(
                        '배송지를 선택해주세요.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: _fontFamily,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAddress!.recipientName ??
                                _selectedAddress!.name ??
                                '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: _fontFamily,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress!.phoneNumber ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: _fontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedAddress!.address ?? ''} ${(_selectedAddress!.detailedAddress ?? '').trim()}'
                                .trim(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: _fontFamily,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          if ((_selectedAddress!.requestsForDelivery ?? '')
                              .trim()
                              .isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _selectedAddress!.requestsForDelivery!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: _fontFamily,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _manageAddresses,
                              style: TextButton.styleFrom(
                                backgroundColor: _sectionDivider,
                                foregroundColor: cs.onSurface,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              child: const Text('배송지 변경'),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: _sectionGap),

              // Idden (상품 정보)
              _buildSection(
                context,
                label: 'Idden',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...widget.items.map((item) {
                      final imageUrl =
                          item.product.mainImageBucket != null &&
                              item.product.mainImageFileName != null
                          ? getImageLink(
                              item.product.mainImageBucket!,
                              item.product.mainImageFileName!,
                              folderPath: item.product.mainImageFolderPath,
                            )
                          : null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 64,
                                      height: 64,
                                      color: cs.surfaceContainerHighest,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 64,
                                    height: 64,
                                    color: cs.surfaceContainerHighest,
                                    child: const Icon(Icons.image),
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 64,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.product.title ??
                                          item.product.name ??
                                          '제품명 없음',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontFamily: _fontFamily,
                                            fontWeight: FontWeight.normal,
                                          ),
                                    ),
                                    Text(
                                      '수량: ${item.quantity}개',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontFamily: _fontFamily,
                                            color: _quantityGray,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              '총 정가 ${formatter.format(item.totalPrice.toInt())}원',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: _fontFamily,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: _sectionDivider,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _handleUseMileageChanged(!_useMileage),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IgnorePointer(
                                    child: Checkbox(
                                      value: _useMileage,
                                      onChanged: (_) {},
                                      activeColor: cs.primary,
                                    ),
                                  ),
                                  Text(
                                    '마일리지 사용',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontFamily: _fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _awardPointsController,
                                focusNode: _awardPointsFocusNode,
                                keyboardType: TextInputType.number,
                                enabled: _useMileage,
                                textAlign: TextAlign.right,
                                style: TextStyle(fontFamily: _fontFamily),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(
                                      color: _inputBorder,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(
                                      color: _inputBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: BorderSide(color: cs.primary),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                ),
                                onTap: () {
                                  if (!_useMileage) {
                                    _handleUseMileageChanged(true);
                                  }
                                },
                                onChanged: _handleAwardPointsChanged,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '원',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: _fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '사용가능한 최대 마일리지 ${formatter.format(_userAwardPoints.toInt())}원',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: _fontFamily,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '최대 마일리지 적용금액 ${formatter.format(_maxUsableAwardPoints.toInt())}원',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: _fontFamily,
                              color: _mileageOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '합계',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: _fontFamily,
                          ),
                        ),
                        Text(
                          '${formatter.format(productTotal.toInt())}원',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: _sectionDivider,
                          foregroundColor: cs.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          '상품합계 ${formatter.format(productTotal.toInt())}원 - ${formatter.format(mileageUsed.toInt())}원 = ${formatter.format((productTotal - mileageUsed).toInt())}원',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: _fontFamily,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _sectionGap),

              // 결제할 상품 총 N개 + 쿠폰
              _buildSection(
                context,
                label: '결제할 상품 총 ${widget.items.length}개',
                trailing: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurfaceVariant,
                    side: const BorderSide(color: _inputBorder),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text('쿠폰'),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryRow(
                      theme,
                      '총 상품금액',
                      '${formatter.format(productTotal.toInt())}원',
                    ),
                    _buildSummaryRow(
                      theme,
                      '마일리지',
                      mileageUsed > 0
                          ? '-${formatter.format(mileageUsed.toInt())}원'
                          : '0원',
                    ),
                    _buildSummaryRow(
                      theme,
                      '쿠폰',
                      couponDiscount > 0
                          ? '-${formatter.format(couponDiscount.toInt())}원'
                          : '0원',
                    ),
                    _buildSummaryRow(
                      theme,
                      '배송비',
                      '${formatter.format(_shippingFee)}원',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 결제금액',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${formatter.format(totalPayment.toInt())}원',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _sectionGap),

              // 결제 수단
              _buildSection(
                context,
                label: '결제 수단',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            value: _selectedPaymentMethod == 0,
                            onChanged: (v) => setState(
                              () =>
                                  _selectedPaymentMethod = v == true ? 0 : null,
                            ),
                            title: Text(
                              _paymentMethodLabels[0],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: _fontFamily,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: cs.primary,
                          ),
                          CheckboxListTile(
                            value: _selectedPaymentMethod == 1,
                            onChanged: (v) => setState(
                              () =>
                                  _selectedPaymentMethod = v == true ? 1 : null,
                            ),
                            title: Text(
                              _paymentMethodLabels[1],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: _fontFamily,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: cs.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            value: _selectedPaymentMethod == 2,
                            onChanged: (v) => setState(
                              () =>
                                  _selectedPaymentMethod = v == true ? 2 : null,
                            ),
                            title: Text(
                              _paymentMethodLabels[2],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: _fontFamily,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: cs.primary,
                          ),
                          CheckboxListTile(
                            value: _selectedPaymentMethod == 3,
                            onChanged: (v) => setState(
                              () =>
                                  _selectedPaymentMethod = v == true ? 3 : null,
                            ),
                            title: Text(
                              _paymentMethodLabels[3],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: _fontFamily,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: cs.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 구매하기: bg #2F473F, no border radius, white text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isSubmitting || _selectedAddress == null
                        ? null
                        : _submitOrder,
                    style: TextButton.styleFrom(
                      backgroundColor: _purchaseButtonBg,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '구매하기',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Horizontal padding used for section label and divider (so divider respects container padding).
  static const double _sectionHorizontalPadding = 20;

  /// Extra padding above the section label.
  static const double _sectionLabelTopPadding = 24;

  /// Padding between section label and divider (reduced for tighter spacing).
  static const double _sectionLabelBottomPadding = 8;

  /// Pill-shaped "G R E E N | S Q U A R E" title — uses the same [AnimatedToggleSwitch]
  /// as [CodeGreenTopHeader] so the rendering is pixel-identical (static, GREEN selected).
  Widget _buildGreenSquareSwitchTitle(ThemeData theme, ColorScheme cs) {
    return SizedBox(
      width: 200,
      child: IgnorePointer(
        child: AnimatedToggleSwitch<bool>.dual(
          current: false,
          first: false,
          second: true,
          customIconBuilder: (context, local, global) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(
                "  G  R  E  E  N  ",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: cs.onPrimary,
                  fontSize: 12,
                ),
              ),
            );
          },
          textBuilder: (value) {
            return Text(
              'S  Q  U  A  R  E',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.primary,
                fontSize: 12,
              ),
            );
          },
          borderWidth: 2.0,
          indicatorTransition: ForegroundIndicatorTransition.fading(),
          style: ToggleStyle(
            borderRadius: BorderRadius.circular(32.0),
            borderColor: cs.onPrimary,
            indicatorColor: cs.primary,
          ),
          height: 32,
          indicatorSize: const Size.fromWidth(2000),
          onChanged: (_) {},
        ),
      ),
    );
  }

  /// Section card: white background, full width, no radius. Label with 1px divider below.
  Widget _buildSection(
    BuildContext context, {
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: _sectionBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _sectionHorizontalPadding,
              _sectionLabelTopPadding,
              _sectionHorizontalPadding,
              _sectionLabelBottomPadding,
            ),
            child: trailing != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: _fontFamily,
                          fontWeight: FontWeight.w500,
                          color: _sectionLabelColor,
                        ),
                      ),
                      trailing,
                    ],
                  )
                : Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w500,
                      color: _sectionLabelColor,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _sectionHorizontalPadding,
            ),
            child: Container(
              height: 1,
              color: _sectionDivider,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_sectionHorizontalPadding),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: _fontFamily,
            color: _inputLabelColor,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: TextStyle(fontFamily: _fontFamily),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: _inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: _inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: _fontFamily,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
