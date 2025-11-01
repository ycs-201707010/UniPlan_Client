import 'package:all_new_uniplan/screens/chatbot.dart';
import 'package:all_new_uniplan/screens/project_chatbot.dart';
import 'package:all_new_uniplan/services/project_chatbot_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatbotListPage extends StatefulWidget {
  const ChatbotListPage({super.key});

  @override
  State<ChatbotListPage> createState() => _ChatbotListPageState();
}

class _ChatbotListPageState extends State<ChatbotListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: chatListTopBar(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingPageButton(
              profilePicUrl: "assets/images/schedule_profile_pic.png",
              mainText: "스케줄봇",
              subText: "사용자 일정 관리",
              target: ChatbotPage(),
            ),
            SettingPageButton(
              profilePicUrl: "assets/images/project_profile_pic.png",
              mainText: "프로젝트봇",
              subText: "사용자 프로젝트 & 하위 목표 관리",
              target: ProjectChatbot(),
            ),
          ],
        ),
      ),
    );
  }
}

// ** 챗봇 목록 화면의 상단 바 **
class chatListTopBar extends StatelessWidget implements PreferredSizeWidget {
  const chatListTopBar({super.key});

  void _showHelpDialog() {}

  void _showSearchDialog() {}

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // 기본 뒤로가기 제거
      elevation: 0, // 그림자 높이
      scrolledUnderElevation: 0, // 스크롤 해도 색상이 변하지 않게
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '유니봇 리스트',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '도움말',
            onPressed: _showHelpDialog,
            padding: EdgeInsets.zero, // 버튼 내부 간격 최소화
            constraints: const BoxConstraints(), // 아이콘 크기 줄이기
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: '검색',
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ** 챗봇 목록의 아이템 **
class SettingPageButton extends StatelessWidget {
  final String? profilePicUrl;
  final String mainText;
  final String subText;
  final Widget target;

  const SettingPageButton({
    super.key,
    this.profilePicUrl,
    required this.mainText,
    required this.subText,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // ✅ 2. "프로젝트봇" 버튼일 경우에만 팝업 로직 실행
        if (mainText == "프로젝트봇") {
          // ✅ 3. 팝업을 띄우고 사용자의 선택(String?)을 기다림
          final String? selectedType = await showDialog<String>(
            context: context,
            builder: (BuildContext dialogContext) {
              return const ProjectTypeDialog(); // 새로 만든 팝업 위젯
            },
          );

          // ✅ 4. 사용자가 무언가를 선택했다면 (null이 아니라면)
          if (selectedType != null && context.mounted) {
            // ✅ 5. Service의 상태를 업데이트
            context.read<ProjectChatbotService>().setSendType(selectedType);

            // ✅ 6. target 화면(ProjectChatbot)으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (pageContext) => target),
            );
          }
          // (selectedType == null 이면 사용자가 '취소'를 누른 것이므로 아무것도 안 함)
        } else {
          // ✅ 7. "프로젝트봇"이 아닌 다른 버튼(스케줄봇 등)의 기존 동작
          Navigator.push(
            context,
            MaterialPageRoute(builder: (pageContext) => target),
          );
        }
      },
      onLongPress: () {},
      splashColor: Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        width: double.infinity, // 부모 위젯의 너비에 맞춤
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(
                profilePicUrl == null
                    ? 'assets/images/bot_profile_pic.png'
                    : profilePicUrl!,
              ),
            ),
            SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainText,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 프로젝트 봇 선택 시 출력될 팝업 위젯
class ProjectTypeDialog extends StatelessWidget {
  const ProjectTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        "유형 선택",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        // 팝업 내용물의 크기를 자식 위젯에 맞게 최소화
        width: 300, // 팝업의 최대 가로 크기 고정 (선택 사항)
        child: Column(
          mainAxisSize: MainAxisSize.min, // 👈 중요: Column 높이를 최소화
          children: [
            Text(
              "어떤 주제의 프로젝트봇과 대화할까요?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // "공부", "운동" 버튼 (가로 배치)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TypeButton(
                  icon: Icons.school_rounded, // 📚
                  text: "공부",
                  color: Colors.lightGreen,
                  onPressed: () {
                    Navigator.pop(context, "공부"); // "공부" 값을 반환하며 팝업 닫기
                  },
                ),
                _TypeButton(
                  icon: Icons.fitness_center_rounded, // 🏋️
                  text: "운동",
                  color: Colors.lightBlue,
                  onPressed: () {
                    Navigator.pop(context, "운동"); // "운동" 값을 반환하며 팝업 닫기
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // "기타" 버튼 (별도 배치)
            _TypeButton(
              icon: Icons.more_horiz_rounded, // 📁
              text: "기타",
              color: Colors.grey,
              onPressed: () {
                // TODO: '기타' 유형 처리
                Navigator.pop(context, "기타");
              },
            ),
          ],
        ),
      ),
      // 팝업 하단 액션 버튼
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null); // 아무 값도 반환하지 않고 팝업 닫기
          },
          child: Text(
            "취소",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

// 팝업 내부에서 사용하는 커스텀 버튼 위젯
class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _TypeButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, // 버튼 가로 크기
      height: 100, // 버튼 세로 크기
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15), // 배경색 (연하게)
          foregroundColor: color, // 아이콘/텍스트 색 (진하게)
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withOpacity(0.3)), // 옅은 테두리
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
