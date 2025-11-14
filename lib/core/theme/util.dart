import 'package:flutter/material.dart';

/// Creates the app TextTheme using asset fonts.
/// Headlines / titles / displays -> EB Garamond
/// Body / labels -> Noto Sans KR
TextTheme createTextTheme(BuildContext context) {
  const bodyFamily = 'Noto Sans KR';
  const displayFamily = 'EB Garamond';
  // Prefer the bundled OTF subset first, then TTC (if it loads), then Noto Sans KR.
  const displayFallback = <String>[
    'Source Han Serif KR',
    'Source Han Serif',
    bodyFamily,
  ];

  final base = Theme.of(context).textTheme;

  // Simple direct copyWith assignments; no helper indirection.
  return base.copyWith(
    // Prefer EB Garamond for Latin; fall back to Source Han Serif (if available
    // on the platform) and then Noto Sans KR for Hangul coverage.
    displayLarge: base.displayLarge?.copyWith(
      fontFamily: displayFamily,
      fontFamilyFallback: displayFallback,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontFamily: displayFamily,
      fontFamilyFallback: displayFallback,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontFamily: displayFamily,
      fontFamilyFallback: displayFallback,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontFamily: displayFamily,
      fontFamilyFallback: displayFallback,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontFamily: displayFamily,
      fontFamilyFallback: displayFallback,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontFamily: displayFamily,
      fontFamilyFallback: displayFallback,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontFamily: displayFamily,
      fontFamilyFallback: displayFallback,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontFamily: displayFamily,
      fontFamilyFallback: displayFallback,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontFamily: displayFamily,
      fontFamilyFallback: displayFallback,
    ),
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: bodyFamily),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: bodyFamily),
    bodySmall: base.bodySmall?.copyWith(fontFamily: bodyFamily),
    labelLarge: base.labelLarge?.copyWith(fontFamily: bodyFamily),
    labelMedium: base.labelMedium?.copyWith(fontFamily: bodyFamily),
    labelSmall: base.labelSmall?.copyWith(fontFamily: bodyFamily),
  );
}
