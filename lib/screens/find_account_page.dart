import 'package:flutter/material.dart';
import 'package:all_new_uniplan/l10n/l10n.dart';
import 'package:all_new_uniplan/widgets/common_text_field.dart';

class FindAccountPage extends StatefulWidget {
  const FindAccountPage({super.key});

  @override
  State<FindAccountPage> createState() => _FindAccountPageState();
}

class _FindAccountPageState extends State<FindAccountPage> {
  // (참고: 클래스명 수정 필요 시 반영하세요)
  // 텍스트 필드 컨트롤러 (로직 연결용)
  final TextEditingController _findIdEmailController = TextEditingController();
  final TextEditingController _findPwIdController = TextEditingController();
  final TextEditingController _findPwEmailController = TextEditingController();

  @override
  void dispose() {
    _findIdEmailController.dispose();
    _findPwIdController.dispose();
    _findPwEmailController.dispose();
    super.dispose();
  }

  // [로직] 아이디 찾기 버튼 클릭 시
  void _onFindIdPressed() {
    final email = _findIdEmailController.text;
    if (email.isEmpty) return;
    print("아이디 찾기 요청: $email");
    // TODO: 여기에 아이디 찾기 API 로직 구현
  }

  // [로직] 비밀번호 찾기 버튼 클릭 시
  void _onFindPwPressed() {
    final id = _findPwIdController.text;
    final email = _findPwEmailController.text;
    if (id.isEmpty || email.isEmpty) return;
    print("비밀번호 찾기 요청: ID=$id, Email=$email");
    // TODO: 여기에 비밀번호 찾기(재설정 메일 발송 등) API 로직 구현
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭의 개수 (아이디 찾기, 비번 찾기)
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n.findAccount,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          // 탭바 (상단 메뉴)
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: context.l10n.findId),
              Tab(text: context.l10n.findPw),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1. 아이디 찾기 화면
            _buildFindIdView(),
            // 2. 비밀번호 찾기 화면
            _buildFindPwView(),
          ],
        ),
      ),
    );
  }

  // 1. 아이디 찾기 탭 UI
  Widget _buildFindIdView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            context.l10n.findIdDescription,
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
          const SizedBox(height: 30),
          CommonTextField(
            controller: _findIdEmailController,
            label: context.l10n.emailInputHint,
            prefixIcon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _onFindIdPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              context.l10n.findId,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 2. 비밀번호 찾기 탭 UI
  Widget _buildFindPwView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            context.l10n.findPwDescription,
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
          const SizedBox(height: 30),
          CommonTextField(
            controller: _findPwIdController,
            label: context.l10n.idInputHint,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _findPwEmailController,
            label: context.l10n.emailInputHint,
            prefixIcon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _onFindPwPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              context.l10n.findPw,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 공통 텍스트 필드 위젯
  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required String label,
  //   required IconData icon,
  //   TextInputType inputType = TextInputType.text,
  // }) {
  //   return TextField(
  //     controller: controller,
  //     keyboardType: inputType,
  //     decoration: InputDecoration(
  //       labelText: label,
  //       prefixIcon: Icon(icon),
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide(
  //           color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
  //         ),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide(
  //           color: Theme.of(context).colorScheme.primary,
  //           width: 2,
  //         ),
  //       ),
  //       filled: true,
  //       fillColor: Theme.of(
  //         context,
  //       ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
  //     ),
  //   );
  // }
}
