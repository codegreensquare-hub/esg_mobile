import 'package:esg_mobile/core/services/database/user_shipping_address.service.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
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

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _requestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _requestController.dispose();
    super.dispose();
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

  void _openCreateAddressSheet() {
    _nameController.clear();
    _recipientNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _detailAddressController.clear();
    _requestController.clear();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        bool reusableBoxesAreOkay = false;
        bool setAsDefault = addresses.isEmpty;
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '새 배송지 추가',
                            style: Theme.of(sheetContext).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(sheetContext).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        label: '배송지명',
                        validator: (value) =>
                            value == null || value.isEmpty ? '필수 입력입니다.' : null,
                      ),
                      _buildTextField(
                        controller: _recipientNameController,
                        label: '수령인 이름',
                        validator: (value) =>
                            value == null || value.isEmpty ? '필수 입력입니다.' : null,
                      ),
                      _buildTextField(
                        controller: _phoneController,
                        label: '전화번호',
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value == null || value.isEmpty ? '필수 입력입니다.' : null,
                      ),
                      _buildTextField(
                        controller: _addressController,
                        label: '주소',
                        validator: (value) =>
                            value == null || value.isEmpty ? '필수 입력입니다.' : null,
                      ),
                      _buildTextField(
                        controller: _detailAddressController,
                        label: '상세 주소',
                      ),
                      _buildTextField(
                        controller: _requestController,
                        label: '배송 요청사항',
                        maxLines: 3,
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('재사용 박스 수령 동의'),
                        value: reusableBoxesAreOkay,
                        onChanged: (value) {
                          setModalState(() {
                            reusableBoxesAreOkay = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('기본 배송지로 설정'),
                        value: setAsDefault,
                        onChanged: (value) {
                          setModalState(() {
                            setAsDefault = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _createAddress(
                            sheetContext,
                            reusableBoxesAreOkay: reusableBoxesAreOkay,
                            setAsDefault: setAsDefault,
                          ),
                          child: const Text('등록하기'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _createAddress(
    BuildContext sheetContext, {
    required bool reusableBoxesAreOkay,
    required bool setAsDefault,
  }) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final created = await UserShippingAddressService.instance.createAddress(
      userId: widget.userId,
      name: _nameController.text.trim(),
      recipientName: _recipientNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      detailedAddress: _detailAddressController.text.trim().isEmpty
          ? null
          : _detailAddressController.text.trim(),
      requestsForDelivery: _requestController.text.trim().isEmpty
          ? null
          : _requestController.text.trim(),
      reusableBoxesAreOkay: reusableBoxesAreOkay,
    );

    if (!mounted) return;

    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송지 등록에 실패했습니다.')),
      );
      return;
    }

    if (setAsDefault && created.id.isNotEmpty) {
      try {
        await UserShippingAddressService.instance.setDefaultAddress(
          userId: widget.userId,
          addressId: created.id,
        );
        defaultAddressId = created.id;
      } catch (e) {
        debugPrint('Error setting default shipping address: $e');
      }
    }

    if (!mounted) return;

    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('배송지가 등록되었습니다.')),
    );
    _loadAddresses();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          backgroundColor:
                                              cs.primary.withValues(alpha: 0.15),
                                        ),
                                      if (address.reusableBoxesAreOkay)
                                        Chip(
                                          label: const Text('재사용 박스 OK'),
                                          backgroundColor:
                                              cs.primaryContainer.withValues(
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
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateAddressSheet,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('새 배송지 추가'),
      ),
    );
  }
}
