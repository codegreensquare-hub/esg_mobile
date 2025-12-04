import 'package:flutter/material.dart';

class GreenSquareInfoPage extends StatelessWidget {
  const GreenSquareInfoPage({
    super.key,
    required this.title,
    required this.body,
    this.backgroundColor,
  });

  final String title;
  final Widget body;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title),
      ),

      body: body,
    );
  }
}
