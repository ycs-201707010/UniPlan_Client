// 사용자 계정에 생성된 '자주 가는 장소'를 관리하는 페이지이다.
// TODO : ListView.builder를 사용해서 사용자가 저장한 장소 리스트를 불러와 위젯 리스트로 출력하기

import 'package:all_new_uniplan/screens/place_add_page.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/place_service.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser!.userId;
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
                      margin: EdgeInsets.only(bottom: 8),
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
                                onPressed: (context) async {
                                  print('주소를 수정할겁니다');

                                  final result = await Navigator.push<bool>(
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

                                  if (result == true) {
                                    // 성공했을 때 Toast 알림
                                    if (!context.mounted)
                                      return; // context 유효성 검사

                                    // TODO : 라이트모드, 다크모드 구분하기
                                    toastification.show(
                                      context:
                                          context, // optional if you use ToastificationWrapper
                                      type: ToastificationType.success,
                                      style: ToastificationStyle.flatColored,
                                      autoCloseDuration: const Duration(
                                        seconds: 3,
                                      ),
                                      title: Text('제하하하하하!! 장소를 수정했다!!'),
                                    );
                                  }
                                },
                                backgroundColor: const Color(0xFF21B7CA),
                                foregroundColor: Colors.white,

                                label: '수정',
                              ),
                              SlidableAction(
                                onPressed: (context) async {
                                  print('주소를 삭제합니다');

                                  // TODO : Dialog를 띄워 정말로 장소를 삭제할 것인지 묻고, 확인 버튼이 눌리면 그때 장소를 삭제 후 닫는걸로.
                                  bool deleteDesided =
                                      false; // 삭제 여부를 저장하는 bool 변수

                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('장소 삭제'),
                                        content: Text('해당 장소를 정말 삭제하시겠습니까?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              deleteDesided = true;
                                              Navigator.of(
                                                context,
                                              ).pop(); // Dialog를 지움
                                            },
                                            child: Text('예'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('아니오'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (deleteDesided == true) {
                                    print(
                                      "삭제하기로 한 $userId의 장소는 : ${place.name}",
                                    );

                                    // 삭제하기를 결정하였다면 여기에서 deleteSchedule() 함수 실행.
                                    bool deletedResult = await placeService
                                        .deletePlace(userId, place.name);

                                    // 삭제 처리가 성공적으로 완료되었다면 (true가 반환되면) Toast 알림을 띄웁니다.
                                    if (deletedResult == true) {
                                      if (!context.mounted) return;
                                      // TODO : 라이트모드, 다크모드 구분하기
                                      toastification.show(
                                        context: context,
                                        type: ToastificationType.custom(
                                          "Schedule Delete",
                                          Theme.of(context).colorScheme.error,
                                          Icons.edit_calendar_outlined,
                                        ),
                                        style: ToastificationStyle.flatColored,
                                        autoCloseDuration: const Duration(
                                          seconds: 3,
                                        ),
                                        title: const Text(
                                          '해당 장소는 성공적으로 삭제되었습니다.',
                                        ),
                                      );
                                    }
                                  }
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
            onPressed: () async {
              print("[System log] 장소 추가하기!");

              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const PlaceAddPage()),
              );

              if (result == true) {
                // 성공했을 때 Toast 알림
                if (!context.mounted) return; // context 유효성 검사

                // TODO : 라이트모드, 다크모드 구분하기
                toastification.show(
                  context: context, // optional if you use ToastificationWrapper
                  type: ToastificationType.success,
                  style: ToastificationStyle.flatColored,
                  autoCloseDuration: const Duration(seconds: 3),
                  title: Text('제하하하하하!! 장소를 등록했다!!'),
                );
              }
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
