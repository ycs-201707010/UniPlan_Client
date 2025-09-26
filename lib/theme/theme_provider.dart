import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // 기본값 -> 시스템의 설정을 따라감
  ThemeMode get themeMode => _themeMode;

  final String _logoImgUrl = "assets/images/logo.png";

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
