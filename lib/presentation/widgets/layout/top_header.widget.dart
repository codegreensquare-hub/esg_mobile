import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:esg_mobile/core/enums/navigations.dart';
import 'package:flutter/material.dart';

/// A reusable top header that renders a SliverAppBar.
class CodeGreenTopHeader extends StatefulWidget {
  const CodeGreenTopHeader({
    super.key,
    this.initialValue = MainTab.greenSquare,
    this.onChanged,
    this.actions,
  });

  final MainTab initialValue;
  final ValueChanged<MainTab>? onChanged;
  final List<Widget>? actions;

  @override
  State<CodeGreenTopHeader> createState() => _CodeGreenTopHeaderState();
}

class _CodeGreenTopHeaderState extends State<CodeGreenTopHeader> {
  late MainTab _selectedTab;

  bool get _switchValue => _selectedTab == MainTab.codeGreen;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CodeGreenTopHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() => _selectedTab = widget.initialValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: false,
      floating: false,
      snap: false,
      leading: SizedBox.shrink(),
      backgroundColor: theme.colorScheme.primary,
      actions: widget.actions,
      title: Center(
        child: SizedBox(
          width: 200,
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
              final selectedTab = value
                  ? MainTab.codeGreen
                  : MainTab.greenSquare;
              setState(() => _selectedTab = selectedTab);
              widget.onChanged?.call(selectedTab);
            },
          ),
        ),
      ),
    );
  }
}
