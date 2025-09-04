// 텍스트, 배경색, 텍스트 색을 매개변수로 받는 재사용 가능한 버튼 클래스.

import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CommonButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
