import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:flutter/material.dart';

/// A reusable sliver-based layout with clear sections:
/// - topHeader: sits at the very top and owns the status-bar SafeArea
/// - navHeader: a floating header (e.g., app bar) that can adjust padding
/// - body: the main sliver content
/// - footer: fills remaining space at the bottom (optional)
class SliverScaffoldLayout extends StatelessWidget {
  final SliverPersistentHeaderDelegate navHeaderDelegate;
  final List<Widget> bodySlivers;
  final Widget? footer;
  final ScrollController? controller;

  const SliverScaffoldLayout({
    super.key,
    required this.navHeaderDelegate,
    required this.bodySlivers,
    this.footer,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        CodeGreenTopHeader(),

        SliverPersistentHeader(
          floating: true,
          pinned: false,
          delegate: navHeaderDelegate,
        ),
        ...bodySlivers,
        if (footer != null)
          SliverFillRemaining(hasScrollBody: false, child: footer!),
      ],
    );
  }
}
