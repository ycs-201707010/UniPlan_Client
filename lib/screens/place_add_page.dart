// 장소를 생성 및 수정하는 페이지이다.

import 'package:all_new_uniplan/screens/location_deside_page.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/place_service.dart';
import 'package:all_new_uniplan/widgets/basicDialog.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // 시간 및 날짜 포맷팅
import 'package:flutter/material.dart';

class PlaceAddPage extends StatefulWidget {
  // 수정 모드로 입장시, 생성자에 수정할 데이터를 받을 파라미터 추가
  // TODO : 나중엔 DB에서 데이터를 불러와야 하니까, 그에 맞춰 양식도 수정해야겠다.
  final String? initialTitle;
  final String? initialAddress;

  const PlaceAddPage({super.key, this.initialTitle, this.initialAddress});

  @override
  State<PlaceAddPage> createState() => _PlaceAddPageState();
}

class _PlaceAddPageState extends State<PlaceAddPage> {
  final TextEditingController titleController =
      TextEditingController(); // 장소 제목을 입력받을 컨트롤러.

  /// 위치 선택
  final TextEditingController locationController = TextEditingController();

  Future<void> pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LocationDesidePage()),
    );

    if (result != null) {
      setState(() {
        locationController.text = result['address']; // ✅ 주소 표시
        // 필요한 경우 위도/경도도 저장 가능
        // double lat = result['lat'];
        // double lng = result['lng'];
      });
    }
  } // 위치 선택 end

  // ✅ 2. 수정 모드인지 아닌지 판별할 변수
  bool get _isEditing => widget.initialTitle != null;

  @override
  void initState() {
    super.initState();
    // ✅ 3. initState에서 전달받은 데이터가 있으면 컨트롤러에 설정
    if (_isEditing) {
      titleController.text = widget.initialTitle!;
      locationController.text = widget.initialAddress!;
    }
  }

  // 일정 추가
  void addPlace() async {
    final authService = context.read<AuthService>();
    final placeService = context.read<PlaceService>();

    final userId = authService.currentUser!.userId;
    final title = titleController.text.trim();
    final location = locationController.text;

    // 유효성 검사
    if (title.isEmpty || location.isEmpty) {
      showAlert(context, "모든 항목을 입력해야 합니다.");
      return;
    }

    final bool isSuccess = await placeService.addPlace(userId, title, location);

    if (!context.mounted) return;

    Navigator.of(context).pop(isSuccess);
  }

  // 일정 수정. _isEditing이 true면 이 메서드가 실행됨.
  void modifyPlace() async {
    final authService = context.read<AuthService>();
    final placeService = context.read<PlaceService>();

    final userId = authService.currentUser!.userId;
    final name = widget.initialTitle!;
    final newName = titleController.text.trim();
    final newAddress = locationController.text;

    // 유효성 검사
    if (newName.isEmpty || newAddress.isEmpty) {
      showAlert(context, "모든 항목을 입력해야 합니다.");
      return;
    }

    final bool isSuccess = await placeService.modifyPlace(
      userId,
      name,
      newName,
      newAddress,
    );

    if (!context.mounted) return;

    Navigator.of(context).pop(isSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // 추가/수정 모드에 따라 상단 바의 제목을 변경하도록
      appBar: TopBar(title: _isEditing ? "장소 수정하기" : "새 장소 추가하기"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("장소 제목"),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5CE546), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("수행 장소"),
              TextField(
                controller: locationController,
                readOnly: true,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.place),
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5CE546), width: 2),
                  ),
                ),
                onTap: pickLocation,
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
              // TODO : 실제 장소를 DB에 추가하고 장소 관리창으로 이동하도록 해야함
              if (_isEditing) {}
              addPlace();
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
