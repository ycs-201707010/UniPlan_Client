import 'package:all_new_uniplan/screens/congrat.dart';
import 'package:all_new_uniplan/widgets/birthdayDatePicker.dart';
import 'package:all_new_uniplan/widgets/button.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../extensions/context_extension.dart';
import 'package:all_new_uniplan/services/auth_service.dart';

// 성별 선택란
enum Gender { male, female, undisclosed }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _userIdController =
      TextEditingController(); // ID 입력란 컨트롤러 (여기서 텍스트 받아옴)
  final _passwordController = TextEditingController(); // 비밀번호 입력란 컨트롤러
  final _passwordConfirmController = TextEditingController(); // 비밀번호 확인란
  final _nicknameController = TextEditingController(); // 닉네임
  final _emailIdController = TextEditingController(); // 이메일 ID
  final _emailDomainController =
      TextEditingController(); // 이메일 주소 (@ 뒤에 오는 naver.com 등)
  DateTime? _selectedBirthday; // 생년월일 저장용 변수

  String _selectedDomain = 'naver.com';
  bool _isCustomDomain = false; // 이메일 주소를 직접 입력하는지 판단함
  Gender? _selectedGender; // 성별이 선택되었는지 상태 변수 추가.

  // 이메일 선택지
  final List<String> domainOptions = [
    'naver.com',
    'gmail.com',
    'kakao.com',
    '직접 입력',
  ];

  String get fullEmail {
    final id = _emailIdController.text.trim();
    final domain =
        _isCustomDomain ? _emailDomainController.text.trim() : _selectedDomain;
    return '$id@$domain';
  }

  // 모든 정보를 기입했는지 판단하는 함수
  bool get isFormValid {
    final id = _emailIdController.text.trim();
    // 이메일 주소를 직접 입력할 경우 입력란의 텍스트를 받아오고, 아니라면 선택한 항목의 텍스트를 받아옴
    final domain =
        _isCustomDomain ? _emailDomainController.text.trim() : _selectedDomain;

    // 모든 항목을 작성하였다면 true 반환
    return _userIdController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordConfirmController.text == _passwordController.text &&
        id.isNotEmpty &&
        domain.isNotEmpty &&
        _selectedBirthday != null &&
        _selectedGender != null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: TopBar(title: '회원가입'),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  '회원가입',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                ),
              ),

              SizedBox(height: 45),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 아이디 입력란
                  Text('아이디', style: TextStyle(fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      SizedBox(
                        width: context.screenWidth * 0.6,
                        child: TextField(
                          controller: _userIdController,
                          decoration: InputDecoration(
                            hintText: '여기에 아이디 입력',
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
                        width: context.screenWidth * 0.3,
                        child: CommonButton(
                          text: '중복확인',
                          onPressed:
                              () => {
                                // TODO : 아이디 중복확인 로직 입력
                              },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // 비밀번호 입력란
                  Text('비밀번호', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: '여기에 비밀번호 입력',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 비밀번호 확인란 : 두 확인란의 내용이 일치해야 회원가입 버튼이 활성화 되게 설계하기
                  Text(
                    '비밀번호 확인',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextField(
                    controller: _passwordConfirmController,
                    decoration: InputDecoration(
                      hintText: '비밀번호 재입력',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 닉네임 입력란
                  Text('닉네임', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      hintText: '여기에 닉네임 입력',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 이메일 입력란
                  Text('이메일', style: TextStyle(fontWeight: FontWeight.w500)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: context.screenWidth * 0.4,
                        child: TextField(
                          controller: _emailIdController, // 이메일 ID
                          decoration: InputDecoration(
                            hintText: '',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '@',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      // 도메인 선택 or 직접입력
                      SizedBox(
                        width: context.screenWidth * 0.4,
                        child:
                            !_isCustomDomain
                                ? DropdownButtonFormField<String>(
                                  value: _selectedDomain,
                                  items:
                                      domainOptions.map((domain) {
                                        return DropdownMenuItem(
                                          value: domain,
                                          child: Text(domain),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value == '직접 입력') {
                                      setState(() {
                                        _isCustomDomain = true;
                                        _selectedDomain = '';
                                      });
                                    } else {
                                      setState(() {
                                        _isCustomDomain = false;
                                        _selectedDomain = value!;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                )
                                : Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            _emailDomainController, // 직접 입력시엔 컨트롤러에 있는 내용을 이메일로 사용.
                                        decoration: InputDecoration(
                                          hintText: '직접 입력',
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_drop_down),
                                      onPressed: () {
                                        setState(() {
                                          _isCustomDomain = false;
                                          _selectedDomain =
                                              'naver.com'; // 기본 선택값
                                        });
                                      },
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // 생년월일 입력란
                  Text('생년월일', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     SizedBox(
                  //       width: context.screenWidth * 0.3,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           TextField(
                  //             keyboardType: TextInputType.number,
                  //             inputFormatters: [
                  //               LengthLimitingTextInputFormatter(4),
                  //               FilteringTextInputFormatter.digitsOnly,
                  //               RangeInputFormatter(
                  //                 min: 1900,
                  //                 max: DateTime.now().year,
                  //               ),
                  //             ],
                  //             decoration: InputDecoration(
                  //               hintText: '년',
                  //               focusedBorder: UnderlineInputBorder(
                  //                 borderSide: BorderSide(
                  //                   color: Color(0xFF5CE546),
                  //                   width: 2,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: context.screenWidth * 0.3,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           TextField(
                  //             keyboardType: TextInputType.number,
                  //             inputFormatters: [
                  //               LengthLimitingTextInputFormatter(2),
                  //               FilteringTextInputFormatter.digitsOnly,
                  //               RangeInputFormatter(min: 1, max: 12),
                  //             ],
                  //             decoration: InputDecoration(
                  //               hintText: '월',
                  //               focusedBorder: UnderlineInputBorder(
                  //                 borderSide: BorderSide(
                  //                   color: Color(0xFF5CE546),
                  //                   width: 2,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: context.screenWidth * 0.3,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           TextField(
                  //             keyboardType: TextInputType.number,
                  //             inputFormatters: [
                  //               LengthLimitingTextInputFormatter(2),
                  //               FilteringTextInputFormatter.digitsOnly,
                  //               RangeInputFormatter(min: 1, max: 31),
                  //             ],
                  //             decoration: InputDecoration(
                  //               hintText: '일',
                  //               focusedBorder: UnderlineInputBorder(
                  //                 borderSide: BorderSide(
                  //                   color: Color(0xFF5CE546),
                  //                   width: 2,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  BirthdayPicker(
                    onDateChanged: (DateTime pickedDate) {
                      setState(() {
                        _selectedBirthday = pickedDate;
                      });
                    },
                  ),

                  SizedBox(height: 20),

                  // 성별 입력란
                  Text('성별', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Radio<Gender>(
                              value: Gender.male,
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            const Text('남자'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<Gender>(
                              value: Gender.female,
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            const Text('여자'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<Gender>(
                              value: Gender.undisclosed,
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            const Text('미공개'),
                          ],
                        ),
                      ),
                    ],
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
            onPressed:
                isFormValid
                    ? () async {
                      // TODO: 회원가입 처리
                      debugPrint('회원가입 진행');
                      debugPrint('ID: ${_userIdController.text}');
                      debugPrint('EMAIL: $fullEmail');
                      debugPrint('BIRTHDAY: $_selectedBirthday');
                      debugPrint('GENDER: $_selectedGender');

                      final authService = context.read<AuthService>();

                      // 사용자가 입력한 정보를 변수에 담아 보낼 것.
                      final String username = _userIdController.text;
                      final String password = _passwordController.text;
                      final String nickname = _nicknameController.text;
                      final String? gender =
                          _selectedGender
                              ?.name; // enum Gender { male, female, secret } 사용 시
                      final DateTime? birthday = _selectedBirthday;
                      final String email = fullEmail;

                      try {
                        await authService.register(
                          username,
                          password,
                          nickname: nickname,
                          gender: gender,
                          birthday: birthday,
                          email: email,
                        );

                        // 회원가입 성공 시 축하 화면으로 이동
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignupCongratPage(),
                            ),
                          );
                        }
                      } catch (e) {
                        print('회원가입 과정에서 에러 발생: $e');
                        // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
                        rethrow;
                      }
                    }
                    : null, // 다 채워지지 않았으면 비활성화.

            child: const Text(
              '회원가입',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
