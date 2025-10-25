import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // 기본값 -> 시스템의 설정을 따라감

  // 생성자에서 초기 테마 모드를 받도록 수정
  ThemeProvider(this._themeMode);

  ThemeMode get themeMode => _themeMode;

  final String _logoImgUrl = "assets/images/logo.png";

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    // 기기에 설정 저장
    final prefs = await SharedPreferences.getInstance();
    // ThemeMode enum을 문자열(.name)로 변환하여 저장 (예: 'dark')
    prefs.setString('themeMode', mode.name);
  }
}
