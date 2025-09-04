// 메인화면
import 'package:all_new_uniplan/screens/chatbot.dart';
import 'package:all_new_uniplan/screens/my_page.dart';
import 'package:all_new_uniplan/services/chatbot_service.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/screens/scheduleSheets.dart';
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
      const MyPage(), // 임시 위젯 (추후 Scaffold로 변경)
      const ChatbotPage(), // 임시 위젯 (추후 ChatBotPage()로 변경)
    ];

    return Scaffold(
      // AppBar를 제거하고, 각 화면 위젯 내부에 개별적으로 배치합니다.
      body: IndexedStack(index: _selectedIndex, children: widgetOptions),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '마이페이지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: '챗봇',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xEE265A3A),
        onTap: _onItemTapped,
      ),
    );
  }
}
