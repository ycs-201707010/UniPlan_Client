import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1b6d00),
      surfaceTint: Color(0xff1b6d00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6be347),
      onPrimaryContainer: Color(0xff176200),
      secondary: Color(0xff326b21),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffb3f498),
      onSecondaryContainer: Color(0xff387126),
      tertiary: Color(0xff006c51),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00e4b0),
      onTertiaryContainer: Color(0xff006049),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff4fcea),
      onSurface: Color(0xff171d13),
      onSurfaceVariant: Color(0xff3e4a38),
      outline: Color(0xff6e7b66),
      outlineVariant: Color(0xffbecbb3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3327),
      inversePrimary: Color(0xff68e044),
      primaryFixed: Color(0xff84fe5e),
      onPrimaryFixed: Color(0xff042100),
      primaryFixedDim: Color(0xff68e044),
      onPrimaryFixedVariant: Color(0xff125200),
      secondaryFixed: Color(0xffb3f498),
      onSecondaryFixed: Color(0xff042100),
      secondaryFixedDim: Color(0xff98d77f),
      onSecondaryFixedVariant: Color(0xff195208),
      tertiaryFixed: Color(0xff44fec8),
      onTertiaryFixed: Color(0xff002117),
      tertiaryFixedDim: Color(0xff00e1ad),
      onTertiaryFixedVariant: Color(0xff00513d),
      surfaceDim: Color(0xffd5ddcc),
      surfaceBright: Color(0xfff4fcea),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeef6e5),
      surfaceContainer: Color(0xffe9f1df),
      surfaceContainerHigh: Color(0xffe3ebda),
      surfaceContainerHighest: Color(0xffdde5d4),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff0c4000),
      surfaceTint: Color(0xff1b6d00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff207e00),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff0c4000),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff417a2e),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003e2e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff007c5e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff4fcea),
      onSurface: Color(0xff0c1309),
      onSurfaceVariant: Color(0xff2e3928),
      outline: Color(0xff4a5643),
      outlineVariant: Color(0xff64715d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3327),
      inversePrimary: Color(0xff68e044),
      primaryFixed: Color(0xff207e00),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff176200),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff417a2e),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff296117),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff007c5e),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff006149),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc1c9b9),
      surfaceBright: Color(0xfff4fcea),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeef6e5),
      surfaceContainer: Color(0xffe3ebda),
      surfaceContainerHigh: Color(0xffd8e0cf),
      surfaceContainerHighest: Color(0xffccd4c4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff083400),
      surfaceTint: Color(0xff1b6d00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff135500),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff083400),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff1c540b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003325),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00543f),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff4fcea),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff242f1f),
      outlineVariant: Color(0xff414d3b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3327),
      inversePrimary: Color(0xff68e044),
      primaryFixed: Color(0xff135500),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0a3c00),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff1c540b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff0a3c00),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff00543f),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003b2b),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb3bbab),
      surfaceBright: Color(0xfff4fcea),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf3e2),
      surfaceContainer: Color(0xffdde5d4),
      surfaceContainerHigh: Color(0xffcfd7c6),
      surfaceContainerHighest: Color(0xffc1c9b9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff90ff6c),
      surfaceTint: Color(0xff68e044),
      onPrimary: Color(0xff0a3900),
      primaryContainer: Color(0xff6be347),
      onPrimaryContainer: Color(0xff176200),
      secondary: Color(0xff98d77f),
      onSecondary: Color(0xff0a3900),
      secondaryContainer: Color(0xff195208),
      onSecondaryContainer: Color(0xff87c56f),
      tertiary: Color(0xff64ffcd),
      onTertiary: Color(0xff003829),
      tertiaryContainer: Color(0xff00e4b0),
      onTertiaryContainer: Color(0xff006049),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0e150b),
      onSurface: Color(0xffdde5d4),
      onSurfaceVariant: Color(0xffbecbb3),
      outline: Color(0xff88957f),
      outlineVariant: Color(0xff3e4a38),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde5d4),
      inversePrimary: Color(0xff1b6d00),
      primaryFixed: Color(0xff84fe5e),
      onPrimaryFixed: Color(0xff042100),
      primaryFixedDim: Color(0xff68e044),
      onPrimaryFixedVariant: Color(0xff125200),
      secondaryFixed: Color(0xffb3f498),
      onSecondaryFixed: Color(0xff042100),
      secondaryFixedDim: Color(0xff98d77f),
      onSecondaryFixedVariant: Color(0xff195208),
      tertiaryFixed: Color(0xff44fec8),
      onTertiaryFixed: Color(0xff002117),
      tertiaryFixedDim: Color(0xff00e1ad),
      onTertiaryFixedVariant: Color(0xff00513d),
      surfaceDim: Color(0xff0e150b),
      surfaceBright: Color(0xff343b2f),
      surfaceContainerLowest: Color(0xff091007),
      surfaceContainerLow: Color(0xff171d13),
      surfaceContainer: Color(0xff1b2217),
      surfaceContainerHigh: Color(0xff252c21),
      surfaceContainerHighest: Color(0xff30372b),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff90ff6c),
      surfaceTint: Color(0xff68e044),
      onPrimary: Color(0xff083400),
      primaryContainer: Color(0xff6be347),
      onPrimaryContainer: Color(0xff0c4200),
      secondary: Color(0xffaded93),
      onSecondary: Color(0xff062d00),
      secondaryContainer: Color(0xff649f4e),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff64ffcd),
      onTertiary: Color(0xff003325),
      tertiaryContainer: Color(0xff00e4b0),
      onTertiaryContainer: Color(0xff004130),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0e150b),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd3e1c8),
      outline: Color(0xffa9b69f),
      outlineVariant: Color(0xff87947f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde5d4),
      inversePrimary: Color(0xff125400),
      primaryFixed: Color(0xff84fe5e),
      onPrimaryFixed: Color(0xff021500),
      primaryFixedDim: Color(0xff68e044),
      onPrimaryFixedVariant: Color(0xff0c4000),
      secondaryFixed: Color(0xffb3f498),
      onSecondaryFixed: Color(0xff021500),
      secondaryFixedDim: Color(0xff98d77f),
      onSecondaryFixedVariant: Color(0xff0c4000),
      tertiaryFixed: Color(0xff44fec8),
      onTertiaryFixed: Color(0xff00150d),
      tertiaryFixedDim: Color(0xff00e1ad),
      onTertiaryFixedVariant: Color(0xff003e2e),
      surfaceDim: Color(0xff0e150b),
      surfaceBright: Color(0xff3f473a),
      surfaceContainerLowest: Color(0xff040903),
      surfaceContainerLow: Color(0xff182015),
      surfaceContainer: Color(0xff232a1f),
      surfaceContainerHigh: Color(0xff2d3529),
      surfaceContainerHighest: Color(0xff384034),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc8ffb0),
      surfaceTint: Color(0xff68e044),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff6be347),
      onPrimaryContainer: Color(0xff021900),
      secondary: Color(0xffc8ffb0),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff94d37b),
      onSecondaryContainer: Color(0xff010f00),
      tertiary: Color(0xffb7ffe1),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff00e4b0),
      onTertiaryContainer: Color(0xff001911),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0e150b),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe7f4dc),
      outlineVariant: Color(0xffbac7af),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde5d4),
      inversePrimary: Color(0xff125400),
      primaryFixed: Color(0xff84fe5e),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff68e044),
      onPrimaryFixedVariant: Color(0xff021500),
      secondaryFixed: Color(0xffb3f498),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff98d77f),
      onSecondaryFixedVariant: Color(0xff021500),
      tertiaryFixed: Color(0xff44fec8),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff00e1ad),
      onTertiaryFixedVariant: Color(0xff00150d),
      surfaceDim: Color(0xff0e150b),
      surfaceBright: Color(0xff4b5245),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b2217),
      surfaceContainer: Color(0xff2b3327),
      surfaceContainerHigh: Color(0xff363e32),
      surfaceContainerHighest: Color(0xff41493c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
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
