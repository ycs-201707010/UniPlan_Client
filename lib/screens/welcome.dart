// 어플리케이션 실행 시 나타날 화면 (비로그인 시)

import 'package:all_new_uniplan/screens/find_login_id.dart';
import 'package:all_new_uniplan/screens/login.dart';
import 'package:all_new_uniplan/screens/signup.dart';
import 'package:flutter/material.dart';

class welcomePage extends StatelessWidget {
  final String logoImg = 'assets/images/logo.png'; // 로고 이미지를 가져올 디렉터리 주소

  const welcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.8,
              child: Container(child: Image.asset(logoImg)),
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
                child: const Text("로그인"),
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
                child: const Text("회원가입"),
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
                  child: Text('아이디 찾기'),
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
                  child: Text('비밀번호 찾기'),
                ),
              ],
            ),
          ], // children
        ),
      ),
    );
  }
}
