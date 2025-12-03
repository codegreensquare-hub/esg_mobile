import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff001a03),
      surfaceTint: Color(0xff446741),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff0e3010),
      onPrimaryContainer: Color(0xff759a70),
      secondary: Color(0xfff0510d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffecce5d),
      onSecondaryContainer: Color(0xff695700),
      tertiary: Color(0xff7f360e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff9e4d24),
      onTertiaryContainer: Color(0xffffdaca),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffcf8f7),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff444748),
      outline: Color(0xff747878),
      outlineVariant: Color(0xffc4c7c8),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffa9d1a3),
      primaryFixed: Color(0xffc5edbd),
      onPrimaryFixed: Color(0xff002104),
      primaryFixedDim: Color(0xffa9d1a3),
      onPrimaryFixedVariant: Color(0xff2c4e2b),
      secondaryFixed: Color(0xffffe173),
      onSecondaryFixed: Color(0xff221b00),
      secondaryFixedDim: Color(0xffe2c555),
      onSecondaryFixedVariant: Color(0xff554500),
      tertiaryFixed: Color(0xffffdbcc),
      onTertiaryFixed: Color(0xff351000),
      tertiaryFixedDim: Color(0xffffb695),
      onTertiaryFixedVariant: Color(0xff783108),
      surfaceDim: Color(0xffddd9d8),
      surfaceBright: Color(0xfffcf8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f1),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e6),
      surfaceContainerHighest: Color(0xffe5e2e0),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff001a03),
      surfaceTint: Color(0xff446741),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff0e3010),
      onPrimaryContainer: Color(0xff99c092),
      secondary: Color(0xff413500),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff816b00),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff612300),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff9e4d24),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f7),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff333738),
      outline: Color(0xff4f5354),
      outlineVariant: Color(0xff6a6e6e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffa9d1a3),
      primaryFixed: Color(0xff52764e),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3a5d38),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff816b00),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff655300),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xffa9562c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff8b3e16),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xfffcf8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f1),
      surfaceContainer: Color(0xffebe7e6),
      surfaceContainerHigh: Color(0xffe0dcdb),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff001a03),
      surfaceTint: Color(0xff446741),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff0e3010),
      onPrimaryContainer: Color(0xffc4ecbc),
      secondary: Color(0xff362b00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff584800),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff501b00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7c330b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f7),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292d2d),
      outlineVariant: Color(0xff464a4a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffa9d1a3),
      primaryFixed: Color(0xff2f512d),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff183a19),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff584800),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff3d3200),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff7c330b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff5b2000),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b7),
      surfaceBright: Color(0xfffcf8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e0),
      surfaceContainerHigh: Color(0xffd7d4d2),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa9d1a3),
      surfaceTint: Color(0xffa9d1a3),
      onPrimary: Color(0xff163716),
      primaryContainer: Color(0xff0e3010),
      onPrimaryContainer: Color(0xff759a70),
      secondary: Color(0xfff0510d),
      onSecondary: Color(0xff3b2f00),
      secondaryContainer: Color(0xffecce5d),
      onSecondaryContainer: Color(0xff695700),
      tertiary: Color(0xffffb695),
      onTertiary: Color(0xff571e00),
      tertiaryContainer: Color(0xff9e4d24),
      onTertiaryContainer: Color(0xffffdaca),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e0),
      onSurfaceVariant: Color(0xffc4c7c8),
      outline: Color(0xff8e9192),
      outlineVariant: Color(0xff444748),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e0),
      inversePrimary: Color(0xff446741),
      primaryFixed: Color(0xffc5edbd),
      onPrimaryFixed: Color(0xff002104),
      primaryFixedDim: Color(0xffa9d1a3),
      onPrimaryFixedVariant: Color(0xff2c4e2b),
      secondaryFixed: Color(0xffffe173),
      onSecondaryFixed: Color(0xff221b00),
      secondaryFixedDim: Color(0xffe2c555),
      onSecondaryFixedVariant: Color(0xff554500),
      tertiaryFixed: Color(0xffffdbcc),
      onTertiaryFixed: Color(0xff351000),
      tertiaryFixedDim: Color(0xffffb695),
      onTertiaryFixedVariant: Color(0xff783108),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3938),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2a2a29),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffbfe7b7),
      surfaceTint: Color(0xffa9d1a3),
      onPrimary: Color(0xff0a2c0d),
      primaryContainer: Color(0xff759a70),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffebab),
      onSecondary: Color(0xff3b2f00),
      secondaryContainer: Color(0xffecce5d),
      onSecondaryContainer: Color(0xff493b00),
      tertiary: Color(0xffffd3c1),
      onTertiary: Color(0xff461700),
      tertiaryContainer: Color(0xffd5784b),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadddd),
      outline: Color(0xffafb2b3),
      outlineVariant: Color(0xff8d9191),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e0),
      inversePrimary: Color(0xff2e502c),
      primaryFixed: Color(0xffc5edbd),
      onPrimaryFixed: Color(0xff001602),
      primaryFixedDim: Color(0xffa9d1a3),
      onPrimaryFixedVariant: Color(0xff1c3d1c),
      secondaryFixed: Color(0xffffe173),
      onSecondaryFixed: Color(0xff161100),
      secondaryFixedDim: Color(0xffe2c555),
      onSecondaryFixedVariant: Color(0xff413500),
      tertiaryFixed: Color(0xffffdbcc),
      onTertiaryFixed: Color(0xff240800),
      tertiaryFixedDim: Color(0xffffb695),
      onTertiaryFixedVariant: Color(0xff612300),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282827),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd2fbca),
      surfaceTint: Color(0xffa9d1a3),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa5cd9f),
      onPrimaryContainer: Color(0xff000f01),
      secondary: Color(0xffffefc0),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffecce5d),
      onSecondaryContainer: Color(0xff221b00),
      tertiary: Color(0xffffece5),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffffb08d),
      onTertiaryContainer: Color(0xff1b0500),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeef0f1),
      outlineVariant: Color(0xffc0c3c4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e0),
      inversePrimary: Color(0xff2e502c),
      primaryFixed: Color(0xffc5edbd),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffa9d1a3),
      onPrimaryFixedVariant: Color(0xff001602),
      secondaryFixed: Color(0xffffe173),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffe2c555),
      onSecondaryFixedVariant: Color(0xff161100),
      tertiaryFixed: Color(0xffffdbcc),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffffb695),
      onTertiaryFixedVariant: Color(0xff240800),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff51504f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff484646),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    // Global default font for any Text not bound to textTheme tokens.
    fontFamily: 'Noto Sans KR',
    fontFamilyFallback: const ['EB Garamond'],
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
