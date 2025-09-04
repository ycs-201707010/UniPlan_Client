// 회원가입을 축하하는 페이지
import 'package:all_new_uniplan/screens/login.dart';
import 'package:flutter/material.dart';

class SignupCongratPage extends StatelessWidget {
  const SignupCongratPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('🎉', style: TextStyle(fontSize: 80)),
              Text(
                '회원가입이 성공적으로 완료되었습니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '가입하신 아이디로 로그인하여\n유니플랜의 다양한 서비스를 사용해보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },

            child: const Text(
              '로그인',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
