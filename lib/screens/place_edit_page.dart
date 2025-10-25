// 사용자 계정에 생성된 '자주 가는 장소'를 관리하는 페이지이다.
// TODO : ListView.builder를 사용해서 사용자가 저장한 장소 리스트를 불러와 위젯 리스트로 출력하기
// TODO : toast가 작동을 안함. 해결해보자
// TODO : 수정/생성/삭제 시 바로 반영되도록 할 것.

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
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: 위젯이 생성되자마자 장소 데이터를 불러오는 함수를 호출함
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlaces();
    });
  }

  // ✅ 2. _loadPlaces 함수 구현 (AuthService도 필요)
  Future<void> _loadPlaces() async {
    final placeService = context.read<PlaceService>();
    final authService = context.read<AuthService>();

    setState(() {
      _isLoading = true;
    });

    try {
      if (authService.isLoggedIn) {
        await placeService.getPlaces(authService.currentUser!.userId);
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text('장소를 불러오는 데 실패했습니다: $e'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '자주 방문하는 장소를 저장하여\n일정 등록 시 사용하실 수 있습니다',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "목록",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),

            // ✅ 4. 로딩 중일 때와 아닐 때 UI 분리
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                  child: ListView.builder(
                    // ✅ 5. itemCount를 categories가 아닌 places.length로 변경
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      // ✅ 6. categories 대신 places[index] 사용
                      final place = places[index];

                      return Container(
                        margin: const EdgeInsets.fromLTRB(15, 0, 15, 8),
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
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PlaceAddPage(
                                              // ✅ 7. place 객체 전체를 전달 (PlaceAddPage 수정 필요)
                                              initialTitle: place.name,
                                              initialAddress: place.address,
                                            ),
                                      ),
                                    );
                                    if (result == true) {
                                      if (!context.mounted) return;
                                      toastification.show(
                                        context: context,
                                        type: ToastificationType.success,
                                        style: ToastificationStyle.flatColored,
                                        autoCloseDuration: const Duration(
                                          seconds: 3,
                                        ),
                                        title: const Text('장소를 성공적으로 수정했습니다.'),
                                      );
                                      // ✅ 8. 수정 완료 후 목록 새로고침
                                      _loadPlaces();
                                    }
                                  },
                                  backgroundColor: const Color(0xFF21B7CA),
                                  foregroundColor: Colors.white,
                                  label: '수정',
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    // ... (삭제 확인 showDialog 로직) ...
                                    // ✅ (showDialog가 true를 반환했을 때)
                                    bool deletedResult = await placeService
                                        .deletePlace(userId, place.name);
                                    if (deletedResult == true) {
                                      if (!context.mounted) return;
                                      toastification.show(
                                        context: context,
                                        type: ToastificationType.error,
                                        style: ToastificationStyle.flatColored,
                                        title: const Text('장소가 삭제되었습니다.'),
                                      );
                                      // ✅ 9. 삭제 완료 후 목록 새로고침 (notifyListeners()만으로도 가능하지만,
                                      //           getPlaces가 최신 목록을 가져오므로 이게 더 확실함)
                                      // _loadPlaces(); // PlaceService의 deletePlace에서 notifyListeners()를 호출한다면 이 줄은 생략 가능
                                    }
                                  },
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  label: '삭제',
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              title: Text(
                                place.name, // ✅ place 객체 사용
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                place.address, // ✅ place 객체 사용
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: bottomInset > 0 ? bottomInset + 20 : 20,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const PlaceAddPage()),
              );
              if (result == true) {
                if (!context.mounted) return;
                toastification.show(
                  context: context,
                  type: ToastificationType.success,
                  style: ToastificationStyle.flatColored,
                  autoCloseDuration: const Duration(seconds: 3),
                  title: const Text('장소를 성공적으로 추가했습니다.'),
                );
                // ✅ 10. 추가 완료 후 목록 새로고침
                _loadPlaces();
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
