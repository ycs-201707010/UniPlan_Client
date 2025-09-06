import 'package:all_new_uniplan/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:all_new_uniplan/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false; // 비밀번호를 감추고 드러내는데 사용되는 토글 변수.

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: TopBar(title: '로그인 하기'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  '회원가입 시 입력하신 아이디로\n로그인해 주세요',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ),

              SizedBox(height: 70),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('아이디', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      hintText: '여기에 아이디 입력',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF5CE546),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  Text('비밀번호', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextField(
                    // _isPasswordVisible가 false일 때 true가 되어 텍스트가 가려진다.
                    obscureText: !_isPasswordVisible,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: '여기에 비밀번호 입력',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF5CE546),
                          width: 2,
                        ),
                      ),

                      suffixIcon: IconButton(
                        icon: Icon(
                          // _isPasswordVisible 상태에 따라 아이콘 모양을 변경한다.
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              }),
                            },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // ✅ 하단 버튼 (키보드에 따라 위로 밀려 올라감)
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: bottomInset > 0 ? bottomInset + 20 : 20, // 키보드가 올라올 때 +10 여유
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () async {
              print("[System log] 로그인 기능 실행");
              if (idController.text == "" || passwordController.text == "") {
                showDialog(
                  context: context,
                  barrierDismissible: true, // 다이얼로그 바깥 영역 터치 시 닫을 지 여부
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('에러'),
                      content: const SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('로그인에 실패했습니다.'),
                            Text('아이디 및 비밀번호를 다시 확인해주십시오.'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('확인'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                ); // showdialog
              }

              final authService = context.read<AuthService>();
              // final scheduleService = context.read<ScheduleService>();

              try {
                await authService.login(
                  idController.text,
                  passwordController.text,
                );

                //final user = authService.currentUser;

                if (authService.isLoggedIn) {
                  print("[System log] 로그인 성공");
                  // await scheduleService.getSchedule(
                  //   authService.currentUser!.userId,
                  // ); home.dart에서 해야할 듯.

                  Navigator.pushReplacement(
                    context, // 여기서 페이지 전환
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  // 사용자가 로그인하지 않은 경우에 대한 처리
                  // ** 다이얼로그를 띄우는 것으로 처리하기 **
                  print("[System log] 로그인 기능 실패함");

                  showDialog(
                    context: context,
                    barrierDismissible: true, // 다이얼로그 바깥 영역 터치 시 닫을 지 여부
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('에러'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('로그인에 실패했습니다.'),
                              Text('아이디 및 비밀번호를 다시 확인해주십시오.'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('확인'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  ); // showdialog
                }
              } catch (e) {
                print("에러 발생 : $e");
                // TODO: 여기서도 로그인 실패 다이얼로그를 보여주면 좋을 듯함.
                showDialog(
                  context: context,
                  barrierDismissible: true, // 다이얼로그 바깥 영역 터치 시 닫을 지 여부
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('에러'),
                      content: const SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('로그인에 실패했습니다.'),
                            Text('아이디 및 비밀번호를 다시 확인해주십시오.'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('확인'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                ); // showdialog
              }
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
