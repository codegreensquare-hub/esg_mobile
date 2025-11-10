import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

/// A reusable top header that renders a SliverAppBar.
class CodeGreenTopHeader extends StatefulWidget {
  const CodeGreenTopHeader({
    super.key,
    this.initialValue = false,
    this.onChanged,
  });

  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  @override
  State<CodeGreenTopHeader> createState() => _CodeGreenTopHeaderState();
}

class _CodeGreenTopHeaderState extends State<CodeGreenTopHeader> {
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: false,
      floating: false,
      snap: false,
      backgroundColor: theme.colorScheme.primary,
      title: SizedBox(
        width: 200,
        child: Center(
          child: AnimatedToggleSwitch<bool>.dual(
            current: _switchValue,
            customIconBuilder: (context, local, global) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text(
                  "  G  R  E  E  N  ",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 12,
                  ),
                ),
              );
            },
            textBuilder: (value) {
              return Text(
                value ? 'C  O  D  E' : 'S  Q  U  A  R  E',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                ),
              );
            },
            first: false,
            second: true,
            borderWidth: 2.0,
            indicatorTransition: ForegroundIndicatorTransition.fading(),
            style: ToggleStyle(
              borderRadius: BorderRadius.circular(32.0),
              borderColor: theme.colorScheme.onPrimary,
              indicatorColor: theme.colorScheme.primary,
            ),
            height: 32,
            indicatorSize: const Size.fromWidth(2000),
            onChanged: (value) {
              setState(() => _switchValue = value);
              widget.onChanged?.call(value);
            },
          ),
        ),
      ),
    );
  }
}
