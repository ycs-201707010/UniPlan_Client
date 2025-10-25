// ** 아이디 찾기 창 **

import 'dart:async';

import 'package:all_new_uniplan/extensions/context_extension.dart';
import 'package:all_new_uniplan/widgets/button.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';

class FindLoginId extends StatefulWidget {
  const FindLoginId({super.key});

  @override
  State<FindLoginId> createState() => _FindLoginIdState();
}

class _FindLoginIdState extends State<FindLoginId> {
  // 입력한 이메일 컨트롤러
  final TextEditingController emailController = TextEditingController();

  // 인증번호 컨트롤러
  final TextEditingController codeController = TextEditingController();

  // 코드가 발송되었는지 확인
  bool _isCodeSent = false;

  // 타이머 변수
  Timer? _timer;
  int _remainingSeconds = 300; // 5분 = 300초

  // 타이머 시작 함수
  void _startTimer() {
    _remainingSeconds = 300; // 타이머 초기화
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          // 시간이 0이 되면 타이머를 멈추고 상태를 초기화
          _timer?.cancel();
          _isCodeSent = false;
          // (선택사항) "인증 시간이 만료되었습니다." SnackBar 표시
        }
      });
    });
  }

  // 남은 시간을 'mm:ss' 형식의 문자열로 변환하는 함수
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    // ✅ 위젯이 사라질 때 컨트롤러와 타이머를 반드시 해제
    emailController.dispose();
    codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: "아이디 찾기"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  '회원가입 시 입력하신 이메일을 입력해주세요',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
                ),
              ),

              SizedBox(height: 50),

              Row(
                children: [
                  SizedBox(
                    width: context.screenWidth * 0.55,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: '여기에 이메일 입력',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  SizedBox(
                    width: context.screenWidth * 0.35,

                    child: CommonButton(
                      text: '인증번호 발송',
                      onPressed:
                          () => {
                            // TODO : 아이디 중복확인 로직 입력
                          },
                    ),
                  ),
                ],
              ),

              if (_isCodeSent)
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '메일로 발송된 인증번호를 입력해주세요',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: codeController,
                              decoration: InputDecoration(
                                hintText: '인증번호 6자리',
                                // 타이머 텍스트를 오른쪽에 표시
                                suffixText: _formatDuration(_remainingSeconds),
                              ),
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: authService.verifyCode(emailController.text, codeController.text) 호출
                              // 성공 시, 서버로부터 받은 아이디를 가지고 다음 페이지로 이동
                              // Navigator.push(context, MaterialPageRoute(builder: (_) => IdFoundPage(userId: '...')));

                              // 성공했다면 타이머 정지
                              _timer?.cancel();
                            },

                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
