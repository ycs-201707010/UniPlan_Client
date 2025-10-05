// ** 일정을 직접 등록하는 화면 **
import 'package:all_new_uniplan/models/place_model.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/screens/location_deside_page.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/place_service.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:all_new_uniplan/widgets/basicDialog.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // 시간 및 날짜 포맷팅

class AddSchedulePage extends StatefulWidget {
  final BuildContext rootContext;
  final Schedule? initialSchedule; // ← null 가능

  const AddSchedulePage({
    super.key,
    required this.rootContext,
    this.initialSchedule,
  });

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  Schedule? originalSchedule;

  String barTitle = '일정 추가하기';
  String buttonTitle = '일정 추가하기';

  // 이미 등록된 일정 수정 시, 날짜를 포맷
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('a h : mm', 'en').format(dt); // 예: 오후 1시 30분
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialSchedule != null) {
      barTitle = '일정 수정하기';
      buttonTitle = '일정 수정하기';

      final schedule = widget.initialSchedule!;

      selectedDate = schedule.date;
      startTime = schedule.startTime;
      endTime = schedule.endTime;
      dateController.text = DateFormat(
        'yyyy-MM-dd (E)',
        'en',
      ).format(schedule.date);
      startTimeController.text = _formatTime(schedule.startTime);
      endTimeController.text = _formatTime(schedule.endTime);
      titleController.text = schedule.title;
      locationController.text =
          schedule.location!; // 느낌표를 붙여서 값이 존재하지 않을 수 있는 필드에 대한 처리를 해줌.
      memoController.text = schedule.memo!;

      originalSchedule = widget.initialSchedule!;
    }
  }

  // Dialog 출력 함수. 재사용하기 위해 만듦.
  // void showAlert(String message) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text("입력 오류"),
  //           content: Text(message),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text("확인"),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  // 시간 비교를 위한 보조 함수.
  int _timeOfDayToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  /// 날짜 선택
  DateTime? selectedDate;

  final TextEditingController titleController = TextEditingController(); // 일정명

  /// form의 input과 같은 입력란의 내용을 바꾸려면 이 컨트롤러 모듈이 필요한듯.
  final TextEditingController dateController = TextEditingController();

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // 과거 제거용

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: today, // 오늘 이전의 날짜는 선택 불가임.
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ko'),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd (E)', 'en').format(picked);
      });
    }
  }

  /// 날짜 선택 end

  /// 시간 선택
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  /// 수행일이 오늘 날짜인지를 판단함.
  TimeOfDay getInitialTime() {
    final now = DateTime.now();
    final isToday =
        selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;

    return isToday ? TimeOfDay.now() : const TimeOfDay(hour: 0, minute: 0);
  }

  Future<void> pickTime(BuildContext context, bool isStart) async {
    // 수행일이 선택되지 않았다면 알림.
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 수행일을 선택하세요.'),
          behavior: SnackBarBehavior.floating, // ✅ 고정형 대신 '떠 있는' 위치로
          margin: EdgeInsets.only(
            bottom: 80,
            left: 16,
            right: 16,
          ), // ✅ BottomSheet 위로 띄우기
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: getInitialTime(),
    );

    if (picked != null) {
      // 유효성 검사
      final now = DateTime.now();
      final isToday =
          selectedDate!.year == now.year &&
          selectedDate!.month == now.month &&
          selectedDate!.day == now.day;

      // 선택한 날짜가 오늘이고, 선택한 시간이 현재 시간보다 이전인 경우
      if (isToday &&
          (picked.hour < now.hour ||
              (picked.hour == now.hour && picked.minute < now.minute))) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('현재 시간보다 이전 시간을 선택할 수 없습니다.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );
        return;
      }
      //유효성 검사 끝

      setState(() {
        /// final 변수 3종 :
        final now = DateTime.now(); // 아무 날짜나 쓰면 됨
        final dt = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour, // picked에 주목.
          picked.minute,
        );
        final formattedTime = DateFormat(
          'a h : mm',
          'en',
        ).format(dt); // → 오후 3:30 // ✅ 포맷된 시간

        if (isStart) {
          startTime = picked;
          startTimeController.text = formattedTime;
        } else {
          endTime = picked;
          endTimeController.text = formattedTime;
        }
      });
    }
  } // 시간 선택 end

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

  /// 메모 작성
  final TextEditingController memoController = TextEditingController();

  // 일정 추가. initialSchedule을 받지 않았다면 onPressed에서 이 메서드를 실행.
  void addSchedule() async {
    final authService =
        context.read<AuthService>(); // 일정을 추가하는데 userId를 가져오기 위함
    final scheduleService = context.read<ScheduleService>();

    final userId = authService.currentUser!.userId;
    final title = titleController.text.trim();
    final date = selectedDate;
    final start = startTime;
    final end = endTime;
    String? location;
    String? memo;
    String color = colorToHex(_selectedColor);

    if (locationController.text != "") {
      location = locationController.text;
    }

    if (memoController.text != "") {
      memo = memoController.text.trim();
    }

    // ✅ 통합 유효성 검사
    if (title.isEmpty || date == null || start == null || end == null) {
      showAlert(context, "장소와 메모란을 제외한 모든 항목을 입력해야 합니다.");
      return;
    }
    if (_timeOfDayToMinutes(start) >= _timeOfDayToMinutes(end)) {
      showAlert(context, "시작 시간은 종료 시간보다 이전이어야 합니다.");
      return;
    }

    // print("🟣 [일정 등록 시도]");
    // print("일정명: $title");
    // print("날짜: $date");
    // print("시작 시간: ${start?.format(context)}");
    // print("종료 시간: ${end?.format(context)}");
    // print("장소: $location");
    // print("메모: $memo");

    // 이후 캘린더에 넘길 데이터 구조로 저장
    // 느낌표는 지워도, 그대로 작성해도 무방함
    final bool isSuccess = await scheduleService.addSchedule(
      userId,
      title,
      date,
      start,
      end,
      location: location,
      memo: memo,
      isLongProject: false,
      color: color,
    );

    if (!context.mounted) return;

    Navigator.of(context).pop(isSuccess);
  }

  // 현재 선택된 색상을 저장할 상태 변수. 초기값은 녹색
  Color _pickerColor = Color(0xFF00FFA3); // 컬러피커로 고른 색상
  Color _selectedColor = Color(0xFF00FFA3); // 실제 일정 생성 시 적용 될 색상

  // 색상을 변경하는 함수
  void changeColor(color) {
    setState(() {
      _pickerColor = color;
    });
  }

  // 컬러피커 호출 함수
  Future pickColor(type) {
    // 매개변수로 받은 컬러피커의 종류 확인
    Widget pickerType;

    if (type == 'ColorPicker') {
      pickerType = ColorPicker(
        pickerColor: _pickerColor,
        onColorChanged: changeColor,
      );
    } else if (type == 'MaterialPicker') {
      pickerType = MaterialPicker(
        pickerColor: _pickerColor,
        onColorChanged: changeColor,
      );
    } else {
      pickerType = BlockPicker(
        pickerColor: _pickerColor,
        onColorChanged: changeColor,
      );
    }

    // 컬러피커 다이얼로그 호출
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('색상을 선택하세요.'),
          content: SingleChildScrollView(child: pickerType),
          actions: <Widget>[
            // 버튼 터치 시 선택한 색상으로 업데이트
            ElevatedButton(
              child: const Text('색 선택'),
              onPressed: () {
                setState(() => _selectedColor = _pickerColor);
                print("selected: $_selectedColor, picked: $_pickerColor");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Color 형식의 데이터를 6자리의
  String colorToHex(Color color) {
    String argb = color.toARGB32().toRadixString(16).padLeft(8, "0");

    return '#${argb.substring(2, 8)}';
  }

  // 일정 수정. initialSchedule을 받았다면 이 메서드를 실행.
  void modifySchedule() async {
    final authService =
        context.read<AuthService>(); // 일정을 추가하는데 userId를 가져오기 위함
    final scheduleService = context.read<ScheduleService>();

    final userId = authService.currentUser!.userId;
    final title = titleController.text.trim();
    final date = selectedDate;
    final start = startTime;
    final end = endTime;
    String? location;
    String? memo;
    String? color = colorToHex(_selectedColor);

    if (locationController.text != "") {
      location = locationController.text;
    }

    if (memoController.text != "") {
      memo = memoController.text.trim();
    }

    // ✅ 통합 유효성 검사
    if (title.isEmpty || date == null || start == null || end == null) {
      showAlert(context, "장소와 메모란을 제외한 모든 항목을 입력해야 합니다.");
      return;
    }
    if (_timeOfDayToMinutes(start) >= _timeOfDayToMinutes(end)) {
      showAlert(context, "시작 시간은 종료 시간보다 이전이어야 합니다.");
      return;
    }

    // 이후 캘린더에 넘길 데이터 구조로 저장
    // scheduleService의 modifySchedule에 전달할 newSchedule 객체를 만들기
    Schedule newSchedule = Schedule(
      title: title,
      date: date,
      startTime: startTime!,
      endTime: endTime!,
      location: location,
      memo: memo,
      isLongProject: false,
      color: color,
    );

    // TODO : 여기에서 modifySchedule() 함수 실행
    final bool isSuccess = await scheduleService.modifySchedule(
      userId,
      originalSchedule!,
      newSchedule,
    );

    if (!context.mounted) return;

    Navigator.of(context).pop(isSuccess);
  }

  // ✅ 1. 선택된 장소를 저장할 상태 변수 추가
  Place? _selectedPlace;

  @override
  void dispose() {
    // 컨트롤러들을 해제합니다.
    titleController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    locationController.dispose();
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PlaceService 인스턴스를 가져옵니다.
    final placeService = context.watch<PlaceService>();
    final places = placeService.placeList;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: TopBar(title: barTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("일정 제목"),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5CE546), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("수행일"),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                  ), // ✅ 세로 정렬 중앙
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5CE546), width: 2),
                  ),
                ),
                readOnly: true,
                onTap: () {
                  // showDatePicker
                  pickDate(context);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: '시작 시간',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF5CE546),
                            width: 2,
                          ),
                        ),
                      ),
                      onTap: () => pickTime(context, true),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: '종료 시간',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF5CE546),
                            width: 2,
                          ),
                        ),
                      ),
                      onTap: () => pickTime(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("수행 장소"),
              // TextField(
              //   controller: locationController,
              //   readOnly: true,
              //   decoration: const InputDecoration(
              //     suffixIcon: Icon(Icons.place),
              //     contentPadding: EdgeInsets.symmetric(vertical: 14),
              //     focusedBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(color: Color(0xFF5CE546), width: 2),
              //     ),
              //   ),
              //   onTap: pickLocation,
              // ),
              // ✅ 2. 기존 TextField를 DropdownButtonFormField로 교체
              DropdownButtonFormField<Object>(
                // 현재 선택된 값을 표시 (UI 업데이트용)
                value: _selectedPlace,
                isExpanded: true, // 텍스트가 길 경우를 대비
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.place),
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5CE546), width: 2),
                  ),
                ),
                hint: const Text('장소 선택'), // 아무것도 선택되지 않았을 때 표시될 텍스트
                // ✅ 3. 아이템 목록 동적 생성
                items: [
                  // '직접 선택' 메뉴 아이템을 맨 위에 추가
                  const DropdownMenuItem<Object>(
                    value: 'direct_select', // 특수 값으로 지정
                    child: Text('📍 직접 선택'),
                  ),
                  // PlaceService에서 불러온 장소 목록으로 메뉴 아이템 생성
                  ...places.map<DropdownMenuItem<Object>>((Place place) {
                    return DropdownMenuItem<Object>(
                      value: place, // 값으로 Place 객체 자체를 사용
                      child: Text(place.name),
                    );
                  }),
                ],

                // ✅ 4. 항목을 선택했을 때 실행될 콜백 함수
                onChanged: (Object? newValue) {
                  if (newValue is Place) {
                    // 저장된 장소를 선택한 경우
                    setState(() {
                      _selectedPlace = newValue;
                      locationController.text = newValue.address;
                    });
                  } else if (newValue == 'direct_select') {
                    // '직접 선택'을 선택한 경우
                    setState(() {
                      _selectedPlace = null; // 선택 상태 초기화
                      locationController.clear(); // 텍스트 필드 비우기
                    });
                    pickLocation(); // 기존의 지도 페이지 여는 함수 호출
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text("메모"),
              TextField(
                maxLines: 5,
                controller: memoController,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF5CE546), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text("색상 선택"),
              SizedBox(height: 15),

              GestureDetector(
                onTap: () => pickColor('ColorPicker'),
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
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
            // ** 눌렀을 때 이벤트 **
            onPressed: () async {
              if (originalSchedule != null) {
                modifySchedule();
              } else {
                addSchedule();
              }
            },

            child: Text(
              buttonTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
