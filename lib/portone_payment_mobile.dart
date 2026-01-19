import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:portone_flutter/iamport_payment.dart';
import 'package:portone_flutter/model/payment_data.dart';

class PortonePaymentScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    String readEnv(String key) => (dotenv.env[key] ?? '').trim();

    final mode = readEnv('MODE').toUpperCase();
    final isDev = mode == 'DEV' || mode == 'DEVELOPMENT';

    final appScheme = (dotenv.env['PORTONE_APP_SCHEME'] ?? 'esgmobile').trim();
    final userCode = (isDev ? readEnv('PORTONE_V1_USER_CODE_DEV') : '').ifEmpty(
      readEnv('PORTONE_V1_USER_CODE'),
    );
    final pg = (isDev ? readEnv('PORTONE_V1_PG_DEV') : '')
        .ifEmpty(readEnv('PORTONE_V1_PG'))
        .ifEmpty('html5_inicis');

    final testAmountRaw = isDev ? readEnv('PORTONE_V1_TEST_AMOUNT') : '';
    final totalAmount =
        int.tryParse(testAmountRaw).clampMin(0) ?? amount.toInt();

    final orderName = '${isDev ? '[DEV] ' : ''}ESG Mobile Order Payment'.trim();
    final merchantUid = isDev ? 'dev_$paymentId' : paymentId;

    if (userCode.isEmpty) {
      throw StateError('Missing PORTONE_V1_USER_CODE in .env');
    }

    if (isDev && readEnv('PORTONE_V1_USER_CODE_DEV').isEmpty) {
      debugPrint(
        'MODE=DEV but PORTONE_V1_USER_CODE_DEV is not set; using PORTONE_V1_USER_CODE.',
      );
    }

    return IamportPayment(
      appBar: AppBar(
        title: const Text('PortOne Payment'),
      ),
      initialChild: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
            Text('Please wait...', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      userCode: userCode,
      data: PaymentData(
        pg: pg,
        payMethod: 'card',
        name: orderName,
        merchantUid: merchantUid,
        amount: totalAmount,
        buyerName: buyerName,
        buyerTel: buyerTel,
        buyerEmail: buyerEmail,
        buyerAddr: buyerAddr,
        buyerPostcode: buyerPostcode,
        appScheme: appScheme,
      ),
      callback: (Map<String, String> result) {
        debugPrint('Payment result: $result');
        Navigator.pop(context, result);
      },
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

extension on int? {
  int? clampMin(int min) {
    final value = this;
    if (value == null) return null;
    return value < min ? min : value;
  }
}
