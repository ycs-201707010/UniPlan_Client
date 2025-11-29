import 'package:all_new_uniplan/screens/congrat.dart';
import 'package:all_new_uniplan/widgets/birthdayDatePicker.dart';
import 'package:all_new_uniplan/widgets/button.dart';
import 'package:all_new_uniplan/widgets/common_text_field.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../extensions/context_extension.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:all_new_uniplan/l10n/l10n.dart';

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

  // A. [직접 입력 모드] UI
  Widget _buildCustomDomainInput(AppLocalizations l10n) {
    // l10n 타입은 generated 파일 확인 필요 (보통 AppLocalizations)
    return Row(
      children: [
        Expanded(
          child: CommonTextField(
            controller: _emailDomainController,
            hintText: l10n.customDomain, // "직접 입력"
            inputType: TextInputType.url,
          ),
        ),
        // 드롭다운으로 돌아가는 취소 버튼
        IconButton(
          icon: const Icon(Icons.cancel_outlined),
          color: Theme.of(context).colorScheme.secondary,
          tooltip: '목록 선택으로 돌아가기',
          onPressed: () {
            setState(() {
              _isCustomDomain = false;
              _selectedDomain = 'naver.com'; // 기본값으로 복귀
              _emailDomainController.clear(); // 입력 내용 초기화
            });
          },
        ),
      ],
    );
  }

  // B. [드롭다운 모드] UI (CommonTextField와 디자인 통일)
  Widget _buildDomainDropdown(
    List<String> domainOptions,
    AppLocalizations l10n,
  ) {
    return DropdownButtonFormField<String>(
      value:
          domainOptions.contains(_selectedDomain)
              ? _selectedDomain
              : domainOptions.first,
      isExpanded: true, // 글자가 길어지면 자르지 않고 공간 채움
      decoration: InputDecoration(
        // CommonTextField와 동일한 디자인 적용
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      items:
          domainOptions.map((domain) {
            return DropdownMenuItem(
              value: domain,
              child: Text(
                domain,
                overflow: TextOverflow.ellipsis, // 도메인이 너무 길 경우 ... 처리
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value == l10n.customDomain) {
          // "직접 입력" 선택 시 상태 변경
          setState(() {
            _isCustomDomain = true;
            _selectedDomain = '';
          });
        } else {
          // 일반 도메인 선택 시
          setState(() {
            _isCustomDomain = false;
            _selectedDomain = value!;
          });
        }
      },
    );
  }

  // 성별 라디오 버튼을 생성하는 공통 함수
  // 기존 라디오 버튼을 사용했을 시 픽셀 오버플로우 문제가 발생해서 제작.
  Widget _buildGenderRadio(Gender value, String label) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min, // 내부 Row를 내용물 크기만큼만 차지하게 함
        children: [
          Radio<Gender>(
            value: value,
            groupValue: _selectedGender,
            onChanged: (newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,

            // 🔥 핵심: 라디오 버튼의 기본 여백 제거
            visualDensity: const VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 4), // 라디오 버튼과 텍스트 사이의 아주 좁은 간격
          // 텍스트가 길어질 경우를 대비해 Flexible 추가 (선택 사항)
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14), // 글자 크기 약간 조절
              overflow: TextOverflow.ellipsis, // 공간 부족 시 ... 처리
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final l10n = context.l10n;

    final double publicH = 25;

    // 이메일 도메인 선택지
    final List<String> domainOptions = [
      'naver.com',
      'gmail.com',
      'kakao.com',
      l10n.customDomain, // "직접 입력" or "Custom Input"
    ];

    return Scaffold(
      appBar: TopBar(title: l10n.signup),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          controller: _userIdController,
                          label: l10n.idLabel,
                          hintText: l10n.idHint,
                        ),
                      ),

                      SizedBox(width: 10),

                      SizedBox(
                        width: context.screenWidth * 0.3,
                        child: CommonButton(
                          text: l10n.checkDuplicate,
                          onPressed:
                              () => {
                                // TODO : 아이디 중복확인 로직 입력
                              },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: publicH),

                  CommonTextField(
                    controller: _passwordController,
                    label: l10n.passwordLabel,
                    hintText: l10n.passwordHint,
                    obscureText: true,
                  ),

                  SizedBox(height: publicH),

                  CommonTextField(
                    controller: _passwordConfirmController,
                    label: l10n.passwordConfirmLabel,
                    hintText: l10n.passwordConfirmHint,
                    obscureText: true,
                  ),

                  SizedBox(height: publicH),

                  CommonTextField(
                    controller: _nicknameController,
                    label: l10n.nicknameLabel,
                    hintText: l10n.nicknameHint,
                  ),

                  SizedBox(height: publicH),

                  // 이메일 입력란
                  // Text('이메일', style: TextStyle(fontWeight: FontWeight.w500)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // 위쪽 라인 맞춤
                    children: [
                      // 1. 이메일 아이디 (왼쪽)
                      Expanded(
                        flex: 4, // 비율 조정 (왼쪽을 조금 더 넓게)
                        child: CommonTextField(
                          controller: _emailIdController,
                          hintText: l10n.emailInputHint, // 힌트
                          inputType: TextInputType.emailAddress,
                        ),
                      ),

                      // 2. 골뱅이 (@)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 15.0,
                        ),
                        child: Text(
                          '@',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),

                      // 3. 도메인 (오른쪽): 드롭다운 vs 직접입력 스위칭
                      Expanded(
                        flex: 5, // 비율 조정
                        child:
                            _isCustomDomain
                                ? _buildCustomDomainInput(l10n) // A. 직접 입력 모드
                                : _buildDomainDropdown(
                                  domainOptions,
                                  l10n,
                                ), // B. 드롭다운 모드
                      ),
                    ],
                  ),

                  SizedBox(height: publicH),

                  // 생년월일 입력란
                  Text(
                    l10n.birthdayLabel,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  BirthdayPicker(
                    onDateChanged: (DateTime pickedDate) {
                      setState(() {
                        _selectedBirthday = pickedDate;
                      });
                    },
                  ),

                  SizedBox(height: publicH),

                  // 성별 입력란
                  Text(
                    l10n.genderLabel,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      _buildGenderRadio(Gender.male, l10n.genderMale),
                      _buildGenderRadio(Gender.female, l10n.genderFemale),
                      _buildGenderRadio(
                        Gender.undisclosed,
                        l10n.genderUndisclosed,
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
