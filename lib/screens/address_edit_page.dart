// 사용자 계정에 생성된 '자주 가는 장소'를 관리하는 페이지이다.
// TODO : ListView.builder를 사용해서 사용자가 저장한 장소 리스트를 불러와 위젯 리스트로 출력하기

import 'package:all_new_uniplan/screens/address_add_page.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class addressEditPage extends StatefulWidget {
  const addressEditPage({super.key});

  @override
  State<addressEditPage> createState() => _addressEditPageState();
}

class _addressEditPageState extends State<addressEditPage> {
  // 여기에 사용자 계정에 저장된 장소 리스트를 불러옴
  Map<String, String> categories = {
    '우리 집': '서울특별시 동작구 XX동 123-45',
    '헬스장': '서울특별시 동작구 XX동 456-78',
    '안양대학교': '경기도 안양시 만안구 삼덕로37번길 22',
  };

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: TopBar(title: "장소 관리하기"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  '자주 방문하는 장소를 저장하여\n일정 등록 시 사용하실 수 있습니다',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),

              SizedBox(height: 30),

              Text("목록", style: TextStyle()),

              SizedBox(height: 15),

              Column(
                spacing: 10,
                children:
                    categories.entries.map((entry) {
                      // 각 항목(entry)을 아이콘과 텍스트가 있는 Column 위젯으로 변환
                      return Container(
                        width: double.infinity, // 부모 위젯의 너비에 맞춤

                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xEE7E7E7E)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Slidable(
                            endActionPane: ActionPane(
                              extentRatio: 0.45,
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    print('주소를 수정할겁니다');

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AddressAddPage(
                                              // 현재 항목의 데이터를 전달
                                              initialTitle: entry.key,
                                              initialAddress: entry.value,
                                            ),
                                      ),
                                    );
                                  },
                                  backgroundColor: const Color(0xFF21B7CA),
                                  foregroundColor: Colors.white,

                                  label: '수정',
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    print('주소를 삭제합니다');
                                  },
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  label: '삭제',
                                ),
                              ],
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddressAddPage()),
              );
            },

            child: const Text(
              '장소 추가하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
