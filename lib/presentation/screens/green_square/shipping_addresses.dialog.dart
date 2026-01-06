import 'package:esg_mobile/core/services/database/user_shipping_address.service.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/widgets/green_square/shipping_address_form_sheet.dart';
import 'package:flutter/material.dart';

class ShippingAddressesDialog extends StatefulWidget {
  const ShippingAddressesDialog({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<ShippingAddressesDialog> createState() =>
      _ShippingAddressesDialogState();
}

class _ShippingAddressesDialogState extends State<ShippingAddressesDialog> {
  bool isLoading = true;
  List<UserShippingAddressRow> addresses = [];
  String? defaultAddressId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => isLoading = true);
    final service = UserShippingAddressService.instance;
    final fetchedAddresses = await service.fetchAddresses(widget.userId);
    final fetchedDefault = await service.fetchDefaultAddressId(widget.userId);
    if (!mounted) return;
    setState(() {
      addresses = fetchedAddresses;
      defaultAddressId = fetchedDefault;
      isLoading = false;
    });
  }

  Future<void> _openAddressSheet({
    UserShippingAddressRow? initialAddress,
  }) async {
    final result = await showModalBottomSheet<ShippingAddressFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ShippingAddressFormSheet(
        initialAddress: initialAddress,
        initialSetAsDefault: initialAddress == null
            ? addresses.isEmpty
            : initialAddress.id == defaultAddressId,
      ),
    );

    if (result == null) {
      return;
    }

    if (initialAddress == null) {
      await _createAddress(result);
    } else {
      await _updateAddress(result);
    }
  }

  Future<void> _createAddress(ShippingAddressFormResult result) async {
    final messenger = ScaffoldMessenger.of(context);
    final created = await UserShippingAddressService.instance.createAddress(
      userId: widget.userId,
      name: result.name,
      recipientName: result.recipientName,
      phoneNumber: result.phoneNumber,
      address: result.address,
      detailedAddress: result.detailedAddress,
      requestsForDelivery: result.requestsForDelivery,
      reusableBoxesAreOkay: result.reusableBoxesAreOkay,
    );

    if (!mounted) {
      return;
    }

    if (created == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('배송지 등록에 실패했습니다.')),
      );
      return;
    }

    if (result.setAsDefault && created.id.isNotEmpty) {
      await _setDefaultAddress(created.id);
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('배송지가 등록되었습니다.')),
    );
    _loadAddresses();
  }

  Future<void> _updateAddress(ShippingAddressFormResult result) async {
    final messenger = ScaffoldMessenger.of(context);
    final addressId = result.addressId;
    if (addressId == null) {
      return;
    }

    final updated = await UserShippingAddressService.instance.updateAddress(
      addressId: addressId,
      name: result.name,
      recipientName: result.recipientName,
      phoneNumber: result.phoneNumber,
      address: result.address,
      detailedAddress: result.detailedAddress,
      requestsForDelivery: result.requestsForDelivery,
      reusableBoxesAreOkay: result.reusableBoxesAreOkay,
    );

    if (!mounted) {
      return;
    }

    if (updated == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('배송지 수정에 실패했습니다.')),
      );
      return;
    }

    if (result.setAsDefault && addressId.isNotEmpty) {
      await _setDefaultAddress(addressId);
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('배송지가 수정되었습니다.')),
    );
    _loadAddresses();
  }

  Future<void> _setDefaultAddress(String addressId) async {
    try {
      await UserShippingAddressService.instance.setDefaultAddress(
        userId: widget.userId,
        addressId: addressId,
      );
      if (mounted) {
        setState(() {
          defaultAddressId = addressId;
        });
      } else {
        defaultAddressId = addressId;
      }
    } catch (e) {
      debugPrint('Error setting default shipping address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('배송지 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAddresses,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : addresses.isEmpty
            ? const Center(child: Text('등록된 배송지가 없습니다.'))
            : ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  final isDefault = address.id == defaultAddressId;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      onTap: () => _openAddressSheet(initialAddress: address),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  address.name ?? '배송지',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (isDefault)
                                      Chip(
                                        label: const Text('기본 배송지'),
                                        backgroundColor: cs.primary.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    if (address.reusableBoxesAreOkay)
                                      Chip(
                                        label: const Text('재사용 박스 OK'),
                                        backgroundColor: cs.primaryContainer
                                            .withValues(
                                              alpha: 0.2,
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('수령인: ${address.recipientName ?? '-'}'),
                            Text('전화번호: ${address.phoneNumber ?? '-'}'),
                            const SizedBox(height: 8),
                            Text(address.address ?? ''),
                            if ((address.detailedAddress ?? '').isNotEmpty)
                              Text(address.detailedAddress!),
                            if ((address.requestsForDelivery ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '요청사항: ${address.requestsForDelivery!}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'green-square-shipping-addresses-fab',
        onPressed: () => _openAddressSheet(),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('새 배송지 추가'),
      ),
    );
  }
}
