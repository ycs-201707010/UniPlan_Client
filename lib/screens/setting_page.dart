import 'package:all_new_uniplan/theme/theme_provider.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // 각 스위치의 상태를 관리할 변수들
  bool _isScheduleEnabled = true; // 일정 알림 상태 관리
  final bool _isScheduleEndEnabled = false;
  final bool _isCustomerServiceEnabled = true;
  final bool _isHapticEnabled = true;
  bool _isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    return Scaffold(
      appBar: TopBar(title: "환경설정"),
      backgroundColor: Color(0xEEEEEEEE),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 12, top: 20, bottom: 10),
              child: Text(
                "알림",
                style: TextStyle(
                  color: Color(0xEE7E7E7E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SettingPageButton(
              mainText: "일정 알림",
              subText: "다가올 일정을 실시간으로 알려드려요",
              value: _isScheduleEnabled,
              onChanged: (value) {
                setState(() {
                  _isScheduleEnabled = value;
                });
              },
            ),

            Container(
              padding: EdgeInsets.only(left: 12, top: 20, bottom: 10),
              child: Text(
                "디스플레이",
                style: TextStyle(
                  color: Color(0xEE7E7E7E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SettingPageButton(
              mainText: "다크모드",
              subText: "눈부심 방지 기능입니다.",
              value: _isDarkModeEnabled,
              onChanged: (value) {
                setState(() {
                  // 다크모드
                  _isDarkModeEnabled = value;
                });
                if (value != true) {
                  themeProvider.setThemeMode(ThemeMode.light);
                } else if (value) {
                  themeProvider.setThemeMode(ThemeMode.dark);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingPageButton extends StatelessWidget {
  final String mainText;
  final String subText;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingPageButton({
    super.key,
    required this.mainText,
    required this.subText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 부모 위젯의 너비에 맞춤
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                style: TextStyle(fontSize: 12, color: Color(0xEE505050)),
              ),
            ],
          ),

          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Color(0xEE5CE546), // 켜졌을 때 색상
          ),
        ],
      ),
    );
  }
}
