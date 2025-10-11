import 'package:all_new_uniplan/screens/chatbot.dart';
import 'package:flutter/material.dart';

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
      body: SingleChildScrollView(child: Column()),
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (pageContext) => ChatbotPage()),
        );
      },
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
              radius: 16,
              backgroundImage: AssetImage(
                profilePicUrl == null
                    ? 'assets/images/bot_profile_pic.png'
                    : profilePicUrl!,
              ),
            ),
            Column(
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
          ],
        ),
      ),
    );
  }
}
