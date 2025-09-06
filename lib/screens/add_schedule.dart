// ** 일정을 직접 등록하는 화면 **
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/screens/location_deside_page.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
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
  String barTitle = '일정 추가하기';

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
    }
  }

  // Dialog 출력 함수. 재사용하기 위해 만듦.
  void showAlert(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("입력 오류"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("확인"),
              ),
            ],
          ),
    );
  }

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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final scheduleService = context.watch<ScheduleService>();

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
              final authService =
                  context.read<AuthService>(); // 일정을 추가하는데 userId를 가져오기 위함

              final userId = authService.currentUser!.userId;
              final title = titleController.text.trim();
              final date = selectedDate;
              final start = startTime;
              final end = endTime;
              String? location;
              String? memo;

              if (locationController.text != "") {
                location = locationController.text;
              }

              if (memoController.text != "") {
                memo = memoController.text.trim();
              }

              // ✅ 통합 유효성 검사
              if (title.isEmpty ||
                  date == null ||
                  start == null ||
                  end == null) {
                showAlert("장소와 메모란을 제외한 모든 항목을 입력해야 합니다.");
                return;
              }
              if (_timeOfDayToMinutes(start) >= _timeOfDayToMinutes(end)) {
                showAlert("시작 시간은 종료 시간보다 이전이어야 합니다.");
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
              );

              if (!context.mounted) return;

              Navigator.of(context).pop(isSuccess);
            },

            child: const Text(
              '일정 추가하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
