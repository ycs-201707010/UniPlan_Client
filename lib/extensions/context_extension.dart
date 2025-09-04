// 화면의 가로/세로 너비를 구합니다. 사용자 디바이스의 크기에 맞춰 UI를 제작하기 위해 확장 파일을 만듦.

import 'package:flutter/material.dart';

extension ScreenSizeExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}
