// ** 에브리타임과 연결하여 시간표를 불러오는 페이지 **

import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';

// ** 불러온 과목을 표시하기 위해 만든 임 시 클래스 **

class EverytimeLinkPage extends StatefulWidget {
  const EverytimeLinkPage({super.key});

  @override
  State<EverytimeLinkPage> createState() => _EverytimeLinkPageState();
}

class _EverytimeLinkPageState extends State<EverytimeLinkPage> {
  // URL로부터 과목을 전부 로드했는지 판별하는 상태 변수
  bool loadTimeTable = false;

  final TextEditingController URLController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: "시간표 불러오기"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text(
                '등록된 과목을 다수 불러와\n시간표에 저장할 수 있습니다.',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),

            SizedBox(height: 36),

            Container(
              child: Text(
                '1. 에브리타임 시간표 URL을 입력란에 붙여넣기\n하신 뒤, "시간표 불러오기" 버튼을 눌러주세요',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: URLController,
              decoration: InputDecoration(
                hintText: "여기에 URL 붙여넣기",

                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5CE546), width: 2),
                ),
              ),
            ),

            SizedBox(height: 12),

            InkWell(
              onTap: () {
                // TODO : URL을 통해 시간표에서 과목을 불러오고 리스트에 저장하도록
              },
              borderRadius: BorderRadius.circular(10),
              splashColor: Colors.transparent, // 터치 시 음영 제거
              highlightColor: Colors.transparent, // 길게 눌렀을 때 음영 제거
              child: Container(
                width: double.infinity, // 부모 위젯의 너비에 맞춤
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xEEF91F15), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_everytime.png',
                      width: 48,
                      height: 48,
                    ),

                    Text(
                      "에브리타임 시간표 불러오기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 36),

            Container(
              child: Text(
                '2. 불러온 시간표의 과목 목록을 확인해주세요',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),

            SizedBox(height: 12),

            Container(child: SingleChildScrollView()),
          ],
        ),
      ),
    );
  }
}
