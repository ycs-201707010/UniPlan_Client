// 생년월일 선택 기능을 만들기 위해 숫자 범위를 제한하는 formatter를 만듦.

import 'package:flutter/services.dart';

class RangeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    try {
      final int value = int.parse(newValue.text);
      if (value < min || value > max) return oldValue;
      return newValue;
    } catch (_) {
      return oldValue;
    }
  }
}
