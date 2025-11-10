import 'package:flutter/material.dart';

class CurationShopTab extends StatefulWidget {
  static const tab = 'curation_shop';
  const CurationShopTab({super.key});

  @override
  State<CurationShopTab> createState() => _CurationShopTabState();
}

class _CurationShopTabState extends State<CurationShopTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      child: Center(
        child: Text(
          'Code Green Curation Shop Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
