import 'package:flutter/material.dart';
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
    return IamportPayment(
      appBar: AppBar(
        title: Text('PortOne Payment'),
      ),
      initialChild: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Assuming you have an image asset, replace with your own
            // Image.asset('assets/images/iamport-logo.png'),
            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
            Text('Please wait...', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      userCode: 'iamport', // Replace with your actual user code
      data: PaymentData(
        pg: 'html5_inicis',
        payMethod: 'card',
        name: 'ESG Mobile Order Payment',
        merchantUid: paymentId,
        amount: amount.toInt(),
        buyerName: buyerName,
        buyerTel: buyerTel,
        buyerEmail: buyerEmail,
        buyerAddr: buyerAddr,
        buyerPostcode: buyerPostcode,
        appScheme: 'esgmobile',
        cardQuota: [2, 3],
      ),
      callback: (Map<String, String> result) {
        // Handle the result
        debugPrint('Payment result: $result');
        // Navigate back with result
        Navigator.pop(context, result);
      },
    );
  }
}
