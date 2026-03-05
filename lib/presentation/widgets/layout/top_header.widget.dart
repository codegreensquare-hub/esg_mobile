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
    this.leading,
    this.staticTitle,
  });

  final MainTab initialValue;
  final ValueChanged<MainTab>? onChanged;
  final List<Widget>? actions;
  /// Optional left action (e.g. back button). When set, [staticTitle] can be used for a simple title instead of the tab toggle.
  final Widget? leading;
  /// When [leading] is set, show this as the center title instead of the tab toggle (e.g. 'GREEN SQUARE' for sub-pages).
  final String? staticTitle;

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
    final useStaticTitle = widget.leading != null && widget.staticTitle != null;

    return SliverAppBar(
      pinned: _selectedTab == MainTab.greenSquare ? true : false,
      floating: false,
      snap: false,
      automaticallyImplyLeading: false,
      automaticallyImplyActions: false,
      backgroundColor: theme.colorScheme.primary,
      actions: widget.actions,
      leading: widget.leading ??
          (widget.actions == null || widget.actions!.isEmpty
              ? null
              : const SizedBox.shrink()),
      title: Center(
        child: useStaticTitle
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.staticTitle!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            : SizedBox(
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
                value ? '  C  O  D  E ' : 'S  Q  U  A  R  E',
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
