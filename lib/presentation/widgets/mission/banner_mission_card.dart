import 'package:flutter/material.dart';

/// A banner-style mission card with full-bleed background and rounded corners.
class BannerMissionCard extends StatelessWidget {
  const BannerMissionCard({
    super.key,
    required this.background,
    required this.child,
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.height = 320,
  });

  /// Widget used as the background (typically an image).
  final Widget background;

  /// Foreground content laid on top of the background and gradient.
  final Widget child;

  /// Margin around the card. Matches [GeneralMissionCard] by default.
  final EdgeInsetsGeometry margin;

  /// Fixed height for the banner card.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: background),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
