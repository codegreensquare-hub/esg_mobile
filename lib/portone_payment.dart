import 'package:flutter/material.dart';
import 'package:portone_flutter/iamport_payment.dart';
import 'package:portone_flutter/model/payment_data.dart';

class PortonePaymentScreen extends StatelessWidget {
  const PortonePaymentScreen({super.key});

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
        name: 'Sample Payment',
        merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}',
        amount: 1000, // Example amount
        buyerName: 'John Doe',
        buyerTel: '01012345678',
        buyerEmail: 'example@example.com',
        buyerAddr: 'Seoul, South Korea',
        buyerPostcode: '12345',
        appScheme: 'esgmobile', // Matches the scheme we added
        cardQuota: [2, 3],
      ),
      callback: (Map<String, String> result) {
        // Handle the result
        debugPrint('Payment result: $result');
        // Navigate or show dialog
        Navigator.pop(context, result);
      },
    );
  }
}
