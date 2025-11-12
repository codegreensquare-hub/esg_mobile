import 'package:flutter/material.dart';

class OriginalShopTab extends StatefulWidget {
  static const tab = 'original_shop';
  const OriginalShopTab({super.key});

  @override
  State<OriginalShopTab> createState() => _OriginalShopTabState();
}

class _OriginalShopTabState extends State<OriginalShopTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2000,
      color: Colors.green[100],
      child: Center(
        child: Text(
          'Code Green Original Shop Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
