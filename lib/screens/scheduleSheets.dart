// ** 일정이 보여지는 화면 **

import 'package:all_new_uniplan/screens/schedule_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:all_new_uniplan/screens/add_schedule.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/classes/schedule_data_source.dart';
import 'package:toastification/toastification.dart';

class scheduleSheetsPage extends StatefulWidget {
  const scheduleSheetsPage({super.key});

  @override
  State<scheduleSheetsPage> createState() => _scheduleSheetsPageState();
}

class _scheduleSheetsPageState extends State<scheduleSheetsPage> {
  final CalendarController _calendarController =
      CalendarController(); // SfCalendar에서 날짜를 선택하기 위한 컨트롤러.

  // 로딩 상태를 관리할 변수 추가함 (초기값 true. 처음엔 로딩으로 시작해야 하니까)
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: 위젯이 생성되자마자 일정 데이터를 불러오는 함수를 호출함
    super.initState();

    // addPostFrameCallBack을 사용해서, 위젯이 빌드된 이후에 로드 작업을 수행하도록 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedules();
    });
  }

  // 일정을 불러오는 비동기 함수 생성
  Future<void> _loadSchedules() async {
    // context.read를 사용하여 서비스 인스턴스를 가져옴
    final authService = context.read<AuthService>();
    final scheduleService = context.read<ScheduleService>();

    try {
      if (authService.isLoggedIn) {
        await scheduleService.getSchedule(authService.currentUser!.userId);
      }
    } catch (e) {
      print("일정 로딩 중 에러 발생: $e");
      // 사용자에게 에러 알림 (예: 스낵바)
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('일정 정보를 불러오는 데 실패했습니다.')));
      }
    } finally {
      // 성공/실패 여부와 관계없이 로딩 상태를 false로 변경
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleService = context.watch<ScheduleService>();

    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar(),

          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SfCalendar(
                    view: CalendarView.week,
                    controller: _calendarController,
                    dataSource: ScheduleDataSource(scheduleService.schedules),
                    headerDateFormat: 'yyyy년 MMMM', // 헤더에 표시되는 날짜 형식을 지정
                    headerHeight: 40, // 헤더의 높이를 지정. 이 속성을 0으로 설정하여 헤더 영역을 숨김
                    headerStyle: CalendarHeaderStyle(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      textAlign: TextAlign.left,
                      textStyle: TextStyle(
                        // 텍스트 스타일 지정
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    showDatePickerButton: true,
                    firstDayOfWeek: 1,
                    allowDragAndDrop: false,
                    viewHeaderStyle: ViewHeaderStyle(
                      backgroundColor: Color(0xEEE5FFD2),
                    ),
                    todayHighlightColor: Color(0xEE265A3A),
                    selectionDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Color(0xEE009425), width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      shape: BoxShape.rectangle,
                    ),

                    timeSlotViewSettings: TimeSlotViewSettings(
                      startHour: 6,
                      endHour: 24,
                      timeIntervalHeight: 70,
                      timeFormat: 'HH:mm',
                    ),
                  ),
                ),
              ],
            ),
          ),

          floatingActionButton: SpeedDial(
            icon: Icons.add,
            activeIcon: Icons.close,
            backgroundColor: Color(0xEE265A3A), // 버튼 배경색
            foregroundColor: Colors.white, // 버튼 내부의 아이콘 색

            children: [
              SpeedDialChild(
                child: Icon(Icons.calendar_today),
                label: 'Add Schedule',
                onTap: () async {
                  // 일정 추가 창으로 이동, 일정 추가 결과에 따른 결과를 반환받음.
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (pageContext) =>
                              AddSchedulePage(rootContext: context),
                    ),
                  );

                  // TODO : 일정이 성공적으로 추가되었다면, 일정 추가창에서 캘린더 창으로 bool 형식의 응답을 하고, 일정 추가에 성공한 응답을 받으면 일정이 추가되었다는 Dialog 알림 주기
                  if (result == true) {
                    // 성공했을 때 Toast 알림
                    if (!context.mounted) return; // context 유효성 검사

                    toastification.show(
                      context:
                          context, // optional if you use ToastificationWrapper
                      type: ToastificationType.success,
                      style: ToastificationStyle.flatColored,
                      autoCloseDuration: const Duration(seconds: 3),
                      title: Text('제하하하하하!! 일정을 등록했다!!'),
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // _isLoading이 true일 때만 로딩 화면을 보여줌
        if (_isLoading)
          Container(
            color: const Color(0x80000000), // 반투명 검은 배경 (암전)
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

// 상단의 AppBar
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    // final String yearMonthText = DateFormat(
    //   'yyyy년 MM월',
    // ).format(widget.currentDate);

    return AppBar(
      automaticallyImplyLeading: false, // 강제로 뒤로가기 버튼 제거
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽 : 앱 로고
          Image.asset('assets/images/logo.png', height: 45),
          // 오른쪽 : 도움말 아이콘
        ],
      ),
    );
  }
}
