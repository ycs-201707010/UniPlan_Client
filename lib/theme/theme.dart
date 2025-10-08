import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,

      // --- Primary (주요/강조) ---
      primary: Color(0xFF1bb373), // 가장 중요한 요소 (활성 버튼, FAB 등)
      onPrimary: Color(0xFFFFFFFF), // Primary 색상 위의 텍스트/아이콘 (어두운 녹색)
      primaryContainer: Color(0xFF168f5c), // Primary보다 덜 강조된 컨테이너
      onPrimaryContainer: Color(0xFFFFFFFF), // PrimaryContainer 위의 텍스트/아이콘
      // --- Secondary (보조 - 녹색 계열) ---
      // Primary보다 덜 중요하지만 여전히 녹색 계열의 UI 요소에 사용
      secondary: Color(0xFF66bb6a), // 부드러운 중간 톤 녹색
      onSecondary: Color(0xFFFFFFFF), // Secondary 색상 위의 텍스트/아이콘 (흰색)
      secondaryContainer: Color(0xFF005223), // Secondary의 더 어두운 버전
      onSecondaryContainer: Color(0xFFBEEBC2), // SecondaryContainer 위의 텍스트/아이콘
      // --- Tertiary (추가 강조 - 녹색 계열) ---
      // 가장 은은하거나 보조적인 하이라이트가 필요할 때 사용
      tertiary: Color(0xFFA5D6A7), // 밝고 연한 민트/녹색
      onTertiary: Color(0xFF0F381A), // Tertiary 색상 위의 텍스트/아이콘 (어두운 녹색)
      tertiaryContainer: Color(0xFF274F2E), // Tertiary의 더 어두운 버전
      onTertiaryContainer: Color(0xFFC0F3C2), // TertiaryContainer 위의 텍스트/아이콘
      // --- Error (오류) ---
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),

      // --- Surface (표면/배경) ---
      surface: Color(0xFFFFFFFF), // 카드, 다이얼로그, BottomSheet 등의 배경
      onSurface: Color(0xFF0e0f10), // Surface 위의 기본 텍스트/아이콘 (밝은 회색)
      surfaceContainer: Color(0xFFF9F9F9),
      surfaceContainerHigh: Color(
        0xFFe1e1e5,
      ), // Surface와 미묘하게 다른 표면 (TextField 배경 등)
      onSurfaceVariant: Color(0xFF2E3033), // 전체 배경 위의 텍스트/아이콘
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

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,

      // --- Primary (주요/강조) ---
      primary: Color(0xFF00FFA3), // 가장 중요한 요소 (활성 버튼, FAB 등)
      onPrimary: Color(0xFF0E0F10), // Primary 색상 위의 텍스트/아이콘 (어두운 녹색)
      primaryContainer: Color(0xFF1bb373), // Primary보다 덜 강조된 컨테이너
      onPrimaryContainer: Color(0xFF0e0f10), // PrimaryContainer 위의 텍스트/아이콘
      // --- Secondary (보조 - 녹색 계열) ---
      // Primary보다 덜 중요하지만 여전히 녹색 계열의 UI 요소에 사용
      secondary: Color(0xFF2E8B57), // 차분한 중간 톤 녹색 (SeaGreen)
      onSecondary: Color(0xFFFFFFFF), // Secondary 색상 위의 텍스트/아이콘 (흰색)
      secondaryContainer: Color(0xFF004D40), // Secondary의 더 어두운 버전 (어두운 청록)
      onSecondaryContainer: Color(
        0xFFA7FFEB,
      ), // SecondaryContainer 위의 텍스트/아이콘 (밝은 민트)
      // --- Tertiary (추가 강조 - 녹색 계열) ---
      // 보조적인 하이라이트나 다른 톤의 녹색이 필요할 때 사용
      tertiary: Color(0xFF26A69A), // 청록색 (Teal)
      onTertiary: Color(0xFFFFFFFF), // Tertiary 색상 위의 텍스트/아이콘 (흰색)
      tertiaryContainer: Color(0xFF003731), // Tertiary의 더 어두운 버전
      onTertiaryContainer: Color(0xFF9EF1E3), // TertiaryContainer 위의 텍스트/아이콘
      // --- Error (오류) ---
      error: Color(0xFFFFB4AB), // 오류 메시지, 아이콘 등
      onError: Color(0xFF690005), // Error 색상 위의 텍스트/아이콘
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      // --- Surface (표면/배경) ---
      surface: Color(0xFF141517), // 카드, 다이얼로그, BottomSheet 등의 배경
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
