// 사용자 계정에 생성된 '자주 가는 장소'를 관리하는 페이지이다.
// TODO : ListView.builder를 사용해서 사용자가 저장한 장소 리스트를 불러와 위젯 리스트로 출력하기

import 'package:all_new_uniplan/screens/place_add_page.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/place_service.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class PlaceEditPage extends StatefulWidget {
  const PlaceEditPage({super.key});

  @override
  State<PlaceEditPage> createState() => _PlaceEditPageState();
}

class _PlaceEditPageState extends State<PlaceEditPage> {
  // 로딩 상태를 관리할 변수 추가함 (초기값 true. 처음엔 로딩으로 시작해야 하니까)
  final bool _isLoading = true;

  @override
  void initState() {
    // TODO: 위젯이 생성되자마자 장소 데이터를 불러오는 함수를 호출함
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final placeService = context.watch<PlaceService>();
    final places = placeService.placeList; // 서비스에서 장소 목록 가져오기

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: TopBar(title: "장소 관리하기"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  '자주 방문하는 장소를 저장하여\n일정 등록 시 사용하실 수 있습니다',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),

              SizedBox(height: 30),

              Text(
                "목록",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 15),

              Expanded(
                child: ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.surface,
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
                                          (context) => PlaceAddPage(
                                            // 현재 항목의 데이터를 전달
                                            initialTitle: place.name,
                                            initialAddress: place.address,
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
                                  place.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  place.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
              print("[System log] 장소 추가/수정 기능의 지도 ON");

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlaceAddPage()),
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
