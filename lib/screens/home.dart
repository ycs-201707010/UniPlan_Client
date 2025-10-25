// 메인화면
import 'package:all_new_uniplan/l10n/l10n.dart';
import 'package:all_new_uniplan/screens/chatbot.dart';
import 'package:all_new_uniplan/screens/chatbot_list_page.dart';
import 'package:all_new_uniplan/screens/my_page.dart';
import 'package:all_new_uniplan/screens/project_page.dart';
import 'package:all_new_uniplan/screens/timeTable.dart';
import 'package:all_new_uniplan/services/chatbot_service.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/screens/scheduleSheets.dart';
import 'package:all_new_uniplan/screens/timeTable.dart';
// import 'package:all_new_uniplan/screens/project_chatbot.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 하단 네비게이션 바의 버튼을 클릭하면 바뀜

  // _selectedIndex 변수의 값을 바꾸는 메서드
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const scheduleSheetsPage(), // 0번 탭: 캘린더 화면 (이제 Scaffold 포함)
      const TimetablePage(),
      const ProjectPage(), //TimetablePage(), // 1번 탭 : 대학 시간표 화면
      const ChatbotPage(), //ChatbotPage(), // 임시 위젯 (추후 ChatBotPage()로 변경)
      const MyPage(), // 임시 위젯 (추후 Scaffold로 변경)
    ];

    return Scaffold(
      // AppBar를 제거하고, 각 화면 위젯 내부에 개별적으로 배치합니다.
      body: IndexedStack(index: _selectedIndex, children: widgetOptions),

      bottomNavigationBar: BottomNavigationBar(
        // ✅ 1. 타입을 fixed로 강제 지정
        type: BottomNavigationBarType.fixed,

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // ✅ 2. 비활성화된 아이템의 색상을 명확하게 지정 (선택 사항이지만 권장)
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            // ✅ 2. 하드코딩된 문자열 대신 AppLocalizations 사용
            label: context.l10n.navCalendar,
          ),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: '시간표'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined), // 프로젝트에 어울리는 아이콘으로 변경
            label: context.l10n.navProject,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: context.l10n.navChatbot,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: context.l10n.navMyPage,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
