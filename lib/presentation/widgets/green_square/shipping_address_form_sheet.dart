import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShippingAddressFormResult {
  const ShippingAddressFormResult({
    this.addressId,
    required this.name,
    required this.recipientName,
    required this.phoneNumber,
    required this.address,
    required this.postalCode,
    this.detailedAddress,
    this.requestsForDelivery,
    required this.reusableBoxesAreOkay,
    required this.setAsDefault,
  });

  final String? addressId;
  final String name;
  final String recipientName;
  final String phoneNumber;
  final String address;
  final String postalCode;
  final String? detailedAddress;
  final String? requestsForDelivery;
  final bool reusableBoxesAreOkay;
  final bool setAsDefault;
}

class ShippingAddressFormSheet extends StatefulWidget {
  const ShippingAddressFormSheet({
    super.key,
    this.initialAddress,
    this.initialSetAsDefault = false,
  });

  final UserShippingAddressRow? initialAddress;
  final bool initialSetAsDefault;

  bool get isEditing => initialAddress != null;

  @override
  State<ShippingAddressFormSheet> createState() =>
      _ShippingAddressFormSheetState();
}

class _ShippingAddressFormSheetState extends State<ShippingAddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _recipientNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _detailAddressController;
  late final TextEditingController _requestController;
  late bool _reusableBoxesAreOkay;
  late bool _setAsDefault;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialAddress?.name ?? '',
    );
    _recipientNameController = TextEditingController(
      text: widget.initialAddress?.recipientName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialAddress?.phoneNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.initialAddress?.address ?? '',
    );
    _postalCodeController = TextEditingController(
      text: widget.initialAddress?.postalCode ?? '',
    );
    _detailAddressController = TextEditingController(
      text: widget.initialAddress?.detailedAddress ?? '',
    );
    _requestController = TextEditingController(
      text: widget.initialAddress?.requestsForDelivery ?? '',
    );
    _reusableBoxesAreOkay =
        widget.initialAddress?.reusableBoxesAreOkay ?? false;
    _setAsDefault = widget.initialSetAsDefault;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _detailAddressController.dispose();
    _requestController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = ShippingAddressFormResult(
      addressId: widget.initialAddress?.id,
      name: _nameController.text.trim(),
      recipientName: _recipientNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      detailedAddress: _detailAddressController.text.trim().isEmpty
          ? null
          : _detailAddressController.text.trim(),
      requestsForDelivery: _requestController.text.trim().isEmpty
          ? null
          : _requestController.text.trim(),
      reusableBoxesAreOkay: _reusableBoxesAreOkay,
      setAsDefault: _setAsDefault,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
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
                    widget.isEditing ? '배송지 수정' : '새 배송지 추가',
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SheetTextField(
                controller: _nameController,
                label: '배송지명',
                validator: _requiredValidator,
              ),
              _SheetTextField(
                controller: _recipientNameController,
                label: '수령인 이름',
                validator: _requiredValidator,
              ),
              _SheetTextField(
                controller: _phoneController,
                label: '전화번호',
                validator: _requiredValidator,
                keyboardType: TextInputType.phone,
              ),
              _SheetTextField(
                controller: _addressController,
                label: '주소',
                validator: _requiredValidator,
              ),
              _SheetTextField(
                controller: _postalCodeController,
                label: '우편번호',
                validator: _requiredValidator,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              _SheetTextField(
                controller: _detailAddressController,
                label: '상세 주소',
              ),
              _SheetTextField(
                controller: _requestController,
                label: '배송 요청사항',
                maxLines: 3,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('재사용 박스 수령 동의'),
                value: _reusableBoxesAreOkay,
                onChanged: (value) {
                  setState(() {
                    _reusableBoxesAreOkay = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('기본 배송지로 설정'),
                value: _setAsDefault,
                onChanged: (value) {
                  setState(() {
                    _setAsDefault = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(widget.isEditing ? '수정하기' : '등록하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '필수 입력입니다.';
    }
    return null;
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
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
        inputFormatters: inputFormatters,
      ),
    );
  }
}
