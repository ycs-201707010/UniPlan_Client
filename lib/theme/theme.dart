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

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,

      // --- Primary (주요/강조) ---
      primary: Color(0xFF00FFA3), // 가장 중요한 요소 (활성 버튼, FAB 등)
      onPrimary: Color(0xFF003824), // Primary 색상 위의 텍스트/아이콘 (어두운 녹색)
      primaryContainer: Color(0xFF005238), // Primary보다 덜 강조된 컨테이너
      onPrimaryContainer: Color(0xFF5BFFC0), // PrimaryContainer 위의 텍스트/아이콘
      // --- Secondary (보조) ---
      secondary: Color(0xFFB5CCBA), // 덜 중요한 요소 (필터 칩 등)
      onSecondary: Color(0xFF233428), // Secondary 색상 위의 텍스트/아이콘
      secondaryContainer: Color(0xFF394B3D), // Secondary보다 덜 강조된 컨테이너
      onSecondaryContainer: Color(0xFFD1E8D6),

      // --- Tertiary (추가 강조) ---
      tertiary: Color(0xFFA1CEDC), // 추가적인 강조 색상
      onTertiary: Color(0xFF013640), // Tertiary 색상 위의 텍스트/아이콘
      tertiaryContainer: Color(0xFF1E4D57),
      onTertiaryContainer: Color(0xFFBDEAF8),

      // --- Error (오류) ---
      error: Color(0xFFFFB4AB), // 오류 메시지, 아이콘 등
      onError: Color(0xFF690005), // Error 색상 위의 텍스트/아이콘
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      // --- Surface (표면/배경) ---
      surface: Color.fromARGB(255, 28, 28, 28), // 카드, 다이얼로그, BottomSheet 등의 배경
      onSurface: Color(0xFFFFFFFF), // Surface 위의 기본 텍스트/아이콘 (밝은 회색)
      surfaceContainer: Color(0xFF202224),
      surfaceContainerHigh: Color(
        0xFF424744,
      ), // Surface와 미묘하게 다른 표면 (TextField 배경 등)
      onSurfaceVariant: Color(0xFF9da5b6), // 전체 배경 위의 텍스트/아이콘
      // --- 기타 색상 ---
      outline: Color(0xFF4D4D4D), // 테두리선 (OutlinedButton, Divider 등)
      outlineVariant: Color(0xFF424744),
      shadow: Color(0xFF000000), // 그림자
      scrim: Color(0xFF000000), // 배경을 어둡게 덮는 막 (Scrim)

      inverseSurface: Color(0xFFE4E3E2),
      onInverseSurface: Color(0xFF303130),
      inversePrimary: Color(0xFF006B48),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
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
