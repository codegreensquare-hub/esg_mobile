import 'package:flutter/material.dart';

class LookBookTab extends StatefulWidget {
  static const tab = 'look_book';
  const LookBookTab({super.key});

  @override
  State<LookBookTab> createState() => _LookBookTabState();
}

class _LookBookTabState extends State<LookBookTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      child: Center(
        child: Text(
          'Code Green Look Book Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
