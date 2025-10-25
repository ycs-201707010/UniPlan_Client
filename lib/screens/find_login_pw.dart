import 'dart:async';

import 'package:flutter/material.dart';

class FindLoginPw extends StatefulWidget {
  const FindLoginPw({super.key});

  @override
  State<FindLoginPw> createState() => _FindLoginPwState();
}

class _FindLoginPwState extends State<FindLoginPw> {
  // 입력한 아이디 컨트롤러
  final TextEditingController pwController = TextEditingController();

  // 입력한 이메일 컨트롤러
  final TextEditingController emailController = TextEditingController();

  // 인증번호 컨트롤러
  final TextEditingController codeController = TextEditingController();

  // 코드가 발송되었는지 확인
  final bool _isCodeSent = false;

  // 타이머 변수
  Timer? _timer;
  final int _remainingSeconds = 300; // 5분 = 300초

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
