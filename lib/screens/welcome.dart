// 어플리케이션 실행 시 나타날 화면 (비로그인 시)

import 'package:all_new_uniplan/l10n/l10n.dart';
import 'package:all_new_uniplan/screens/find_login_id.dart';
import 'package:all_new_uniplan/screens/login.dart';
import 'package:all_new_uniplan/screens/signup.dart';
import 'package:flutter/material.dart';

class welcomePage extends StatelessWidget {
  const welcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 1. 현재 테마의 밝기를 확인합니다.
    final brightness = Theme.of(context).brightness;

    // ✅ 2. 밝기에 따라 사용할 로고 이미지 경로를 결정합니다.
    final String logoPath =
        (brightness == Brightness.dark)
            ? 'assets/images/logo_dark.png' // 다크 모드일 때 (배경이 어두울 때)
            : 'assets/images/logo.png'; // 라이트 모드일 때 (배경이 밝을 때) // 로고 이미지를 가져올 디렉터리 주소

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.8,
              child: Container(child: Image.asset(logoPath)),
            ),

            SizedBox(height: 60),

            // 로그인 버튼
            FractionallySizedBox(
              widthFactor: 0.9,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 로그인 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Text(context.l10n.login),
              ),
            ),

            SizedBox(height: 15),

            // 회원가입 버튼
            FractionallySizedBox(
              widthFactor: 0.9,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: 회원가입 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: Text(context.l10n.signup),
              ),
            ),

            SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FindLoginId(),
                      ),
                    );
                  },
                  child: Text(context.l10n.findId),
                ),
                SizedBox(width: 80),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FindLoginId(),
                      ),
                    );
                  },
                  child: Text(context.l10n.findPw),
                ),
              ],
            ),
          ], // children
        ),
      ),
    );
  }
}
