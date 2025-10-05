import 'package:flutter/material.dart';

// ✅ 1. BuildContext를 파라미터로 받도록 수정
void showAlert(BuildContext context, String message, {String title = "입력 오류"}) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title), // ✅ 2. 제목도 파라미터로 받아 유연성 확보
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("확인"),
            ),
          ],
        ),
  );
}
