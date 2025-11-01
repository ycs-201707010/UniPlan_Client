import 'package:all_new_uniplan/services/auth_service.dart'; // ✅ AuthService 사용
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart'; // 👈 사진 변경 시 필요

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // 폼 필드를 제어하기 위한 컨트롤러
  late final TextEditingController _nicknameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;

  // 로딩 상태
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 페이지가 로드될 때 Provider를 통해 현재 사용자 정보를 가져와 컨트롤러에 설정
    // context.read는 initState에서 사용하기에 적합 (변경 사항을 수신할 필요 없음)
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser; // 👈 (가정) currentUser가 있다고 가정

    // (가정) currentUser 객체에 username, email, bio 필드가 있다고 가정
    _nicknameController = TextEditingController(
      text: currentUser?.username ?? '사용자',
    );
    _emailController = TextEditingController(
      text: currentUser?.email ?? '이메일 정보 없음',
    );
    _bioController = TextEditingController(text: ''); // (가정)
  }

  @override
  void dispose() {
    // 페이지가 종료될 때 컨트롤러 리소스를 해제
    _nicknameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// 프로필 사진 변경 로직 (TODO)
  Future<void> _pickImage() async {
    // TODO: image_picker 패키지를 사용하여 갤러리/카메라에서 이미지 선택
    // 1. ImagePicker().pickImage(...)로 이미지 선택
    // 2. 선택된 파일을 Firebase Storage 등에 업로드
    // 3. 업로드된 URL을 authService.updateUserProfile로 전송

    print("프로필 사진 변경 로직 실행");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로필 사진 변경 기능은 아직 구현되지 않았습니다.')),
    );
  }

  /// 프로필 저장 로직
  Future<void> _saveProfile() async {
    if (_isLoading) return; // 중복 저장 방지

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final newNickname = _nicknameController.text;
      final newBio = _bioController.text;

      // TODO: AuthService에 'updateUserProfile' 메서드 구현 필요
      // (가정) 사용자 정보를 업데이트하는 메서드 호출
      // await authService.updateUserProfile(
      //   nickname: newNickname,
      //   bio: newBio,
      // );

      // (임시) 0.5초 딜레이로 저장 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('프로필이 성공적으로 저장되었습니다.')));
        Navigator.pop(context); // 저장 후 뒤로가기
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 중 오류 발생: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필 편집',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // 저장 버튼
          _isLoading
              ? const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              )
              : TextButton(onPressed: _saveProfile, child: const Text('저장')),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // --- 프로필 사진 ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    // (가정) currentUser.profileImageUrl이 있다고 가정
                    backgroundImage: NetworkImage(
                      // context
                      //         .watch<AuthService>()
                      //         .currentUser
                      //         ?.profileImageUrl ??
                      'https://placehold.co/150x150/png',
                    ), // TODO: 기본 이미지 URL
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- 이메일 (읽기 전용) ---
            TextField(
              controller: _emailController,
              readOnly: true, // 읽기 전용
              enabled: false, // 비활성화 (시각적 효과)
              decoration: InputDecoration(
                labelText: '이메일 (변경 불가)',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
            const SizedBox(height: 20),

            // --- 닉네임 ---
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 자기소개 ---
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '자기소개',
                hintText: '자신을 소개하는 간단한 메시지를 남겨보세요.',
                prefixIcon: Icon(Icons.edit_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
