import 'package:all_new_uniplan/screens/address_edit_page.dart';
import 'package:all_new_uniplan/screens/setting_page.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MyPageTopBar(),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 45, backgroundColor: Colors.blueAccent),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "쟁반짜장",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text("프로필 변경하기", style: TextStyle(fontSize: 15)),
                          IconButton(
                            visualDensity: VisualDensity(
                              vertical: -4,
                              horizontal: -4,
                            ), // IconButton의 기본 padding 제거
                            onPressed: () => {},
                            icon: Icon(Icons.arrow_forward_ios, size: 15),
                            splashColor: Colors.transparent, // 클릭 시 음영 제거
                            highlightColor:
                                Colors.transparent, // 길게 눌렀을 때 음영 제거
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 60),
              MyPageButton(
                mainText: "대시보드",
                subText: "나의 활동을 확인할 수 있어요",
                onPressed: () => {print('대시보드 버튼 클릭됨.')},
              ),
              SizedBox(height: 12),
              MyPageButton(
                mainText: "진행중인 이벤트",
                subText: "이벤트에 참여할 기회를 찾아봐요",
                onPressed: () => {print('이벤트 버튼 클릭됨.')},
              ),
              SizedBox(height: 12),
              MyPageButton(
                mainText: "계정 정보 변경",
                subText: "계정 정보 변경은 여기에서 가능해요",
                onPressed: () => {print('대시보드 버튼 클릭됨.')},
              ),
              SizedBox(height: 12),
              MyPageButton(
                mainText: "저장된 장소 관리",
                subText: "자주 방문하는 장소를 관리할 수 있어요",
                onPressed:
                    () => {
                      print('장소 관리 버튼 클릭됨.'),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const addressEditPage(),
                        ),
                      ),
                    },
              ),

              SizedBox(height: 60),

              Text("문의 및 알림", style: TextStyle()),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    MyPageTextMenu(mainText: "약관 및 정책", onPressed: () => {}),
                    SizedBox(width: 120),
                    MyPageTextMenu(mainText: "고객센터", onPressed: () => {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 마이페이지에서 사용할 AppBar 위젯
class MyPageTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MyPageTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // 기본 뒤로가기 제거
      elevation: 0,
      scrolledUnderElevation: 0, // 스크롤 해도 색상이 변하지 않게
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "마이플랜",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed:
              () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingPage()),
                ),
              },
          icon: Icon(Icons.settings),
          tooltip: '환경설정',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 녹색 테두리 버튼 위젯
class MyPageButton extends StatelessWidget {
  final String mainText;
  final String subText;
  final VoidCallback onPressed;

  const MyPageButton({
    super.key,
    required this.mainText,
    required this.subText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.transparent, // 터치 시 음영 제거
      highlightColor: Colors.transparent, // 길게 눌렀을 때 음영 제거
      child: Container(
        width: double.infinity, // 부모 위젯의 너비에 맞춤
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xEE6BE347)),
          borderRadius: BorderRadius.circular(10),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// 텍스트 메뉴 위젯
class MyPageTextMenu extends StatelessWidget {
  final String mainText;
  final VoidCallback onPressed;

  const MyPageTextMenu({
    super.key,
    required this.mainText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      splashColor: Colors.transparent, // 터치 시 음영 제거
      highlightColor: Colors.transparent, // 길게 눌렀을 때 음영 제거
      child: Text(
        mainText,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
