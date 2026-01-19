import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PortonePaymentScreen extends StatefulWidget {
  const PortonePaymentScreen({
    super.key,
    required this.paymentId,
    required this.amount,
    required this.shippingAddressId,
    required this.buyerName,
    required this.buyerTel,
    required this.buyerEmail,
    required this.buyerAddr,
    required this.buyerPostcode,
  });

  final String paymentId;
  final double amount;
  final String shippingAddressId;

  final String buyerName;
  final String buyerTel;
  final String buyerEmail;
  final String buyerAddr;
  final String buyerPostcode;

  @override
  State<PortonePaymentScreen> createState() => _PortonePaymentScreenState();
}

class _PortonePaymentScreenState extends State<PortonePaymentScreen> {
  final bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  String _readEnv(String key) => (dotenv.env[key] ?? '').trim();

  void _initializePayment() {
    try {
      final mode = _readEnv('MODE').toUpperCase();
      final isDev = mode == 'DEV' || mode == 'DEVELOPMENT';

      final userCode = (isDev ? _readEnv('PORTONE_V1_USER_CODE_DEV') : '')
          .ifEmpty(_readEnv('PORTONE_V1_USER_CODE'));

      if (userCode.isEmpty) {
        throw StateError('Missing PORTONE_V1_USER_CODE in .env');
      }

      final pg = (isDev ? _readEnv('PORTONE_V1_PG_DEV') : '')
          .ifEmpty(_readEnv('PORTONE_V1_PG'))
          .ifEmpty('html5_inicis');

      final testAmountRaw = isDev ? _readEnv('PORTONE_V1_TEST_AMOUNT') : '';
      final totalAmount =
          int.tryParse(testAmountRaw)?.clampMin(0) ?? widget.amount.toInt();

      final orderName = '${isDev ? '[DEV] ' : ''}ESG Mobile Order Payment'
          .trim();
      final merchantUid = isDev ? 'dev_${widget.paymentId}' : widget.paymentId;

      // Check if IMP is available
      if (!js.context.hasProperty('IMP')) {
        throw StateError('PortOne JS SDK not loaded');
      }

      final imp = js.context['IMP'];

      // Initialize IMP
      imp.callMethod('init', [userCode]);

      // Prepare payment data
      final paymentData = js.JsObject.jsify({
        'pg': pg,
        'pay_method': 'card',
        'merchant_uid': merchantUid,
        'name': orderName,
        'amount': totalAmount,
        'buyer_email': widget.buyerEmail,
        'buyer_name': widget.buyerName,
        'buyer_tel': widget.buyerTel,
        'buyer_addr': widget.buyerAddr,
        'buyer_postcode': widget.buyerPostcode,
      });

      // Define callback
      final callback = js.JsFunction.withThis((self, result) {
        if (result is js.JsObject) {
          final resultMap = <String, String>{};
          resultMap['imp_success'] = result['success']?.toString() ?? 'false';
          resultMap['imp_uid'] = result['imp_uid']?.toString() ?? '';
          resultMap['merchant_uid'] = result['merchant_uid']?.toString() ?? '';
          resultMap['error_msg'] = result['error_msg']?.toString() ?? '';
          if (!mounted) return;
          Navigator.of(context).pop(resultMap);
        }
      });

      // Request payment
      imp.callMethod('request_pay', [paymentData, callback]);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment Error')),
        body: Center(
          child: Text('Error: $_error'),
        ),
      );
    }

    // For web, the payment is handled by JS, so we show a waiting screen
    return Scaffold(
      appBar: AppBar(title: const Text('PortOne Payment')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Processing payment...', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Please complete the payment in the popup window.'),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

extension on int {
  int clampMin(int min) => this < min ? min : this;
}
