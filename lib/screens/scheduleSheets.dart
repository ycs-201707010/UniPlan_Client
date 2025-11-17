// ** 일정이 보여지는 화면 **

import 'package:all_new_uniplan/l10n/l10n.dart';
import 'package:all_new_uniplan/screens/everytime_link_page.dart';
import 'package:all_new_uniplan/screens/schedule_detail_sheet.dart';
import 'package:all_new_uniplan/services/everytime_service.dart';
import 'package:all_new_uniplan/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:all_new_uniplan/screens/add_schedule.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/classes/schedule_data_source.dart';
import 'package:toastification/toastification.dart';
import 'package:all_new_uniplan/services/place_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class scheduleSheetsPage extends StatefulWidget {
  const scheduleSheetsPage({super.key});

  @override
  State<scheduleSheetsPage> createState() => _scheduleSheetsPageState();
}

class _scheduleSheetsPageState extends State<scheduleSheetsPage>
    with TickerProviderStateMixin {
  final CalendarController _calendarController =
      CalendarController(); // SfCalendar에서 날짜를 선택하기 위한 컨트롤러.

  // 로딩 상태를 관리할 변수 추가함 (초기값 true. 처음엔 로딩으로 시작해야 하니까)
  bool _isLoading = true;

  // 이동시간 표시 여부를 관리할 변수
  bool _showTravelTime = true; // 기본값은 '켜기'

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
    final everytimeService = context.read<EverytimeService>();
    final projectService = context.read<ProjectService>();
    final placeService = context.read<PlaceService>();

    if (authService.isLoggedIn) {
      try {
        await scheduleService.getScheduleByMonth(
          2025,
          11,
          authService.currentUser!.userId,
        );
      } on Exception catch (e) {
        if (e.toString().contains('404')) {
          print("일정이 비어있습니다.");
        } else {
          print("일정 로딩 중 에러 발생: $e");
          // 사용자에게 에러 알림 (예: 스낵바)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('일정 정보를 불러오는 데 실패했습니다.')),
            );
          }
        }
      }
      try {
        await everytimeService.getTimetable(authService.currentUser!.userId);
        print(everytimeService.currentTimetableList!.length);
      } on Exception catch (e) {
        if (e.toString().contains('404')) {
          print("시간표가 비어있습니다.");
        } else {
          print("시간표 로딩 중 에러 발생: $e");
          // 사용자에게 에러 알림 (예: 스낵바)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('시간표 정보를 불러오는 데 실패했습니다.')),
            );
          }
        }
      }

      try {
        await projectService.getProjectByUserId(
          authService.currentUser!.userId,
        );
      } on Exception catch (e) {
        if (e.toString().contains('404')) {
          print("프로젝트가 비어있습니다.");
        } else {
          print("프로젝트 로딩 중 에러 발생: $e");
          // 사용자에게 에러 알림 (예: 스낵바)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('프로젝트 정보를 불러오는 데 실패했습니다.')),
            );
          }
        }
      }

      try {
        await placeService.getPlaces(authService.currentUser!.userId);
      } on Exception catch (e) {
        if (e.toString().contains('404')) {
          print("장소가 비어있습니다.");
        } else {
          print("장소 로딩 중 에러 발생: $e");
          // 사용자에게 에러 알림 (예: 스낵바)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('장소 정보를 불러오는 데 실패했습니다.')),
            );
          }
        }
      }

      // 성공/실패 여부와 관계없이 로딩 상태를 false로 변경
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 오늘 날짜의 요일에 따라 색상을 반환하는 함수
  Color _getTodayHighlightColor() {
    final DateTime today = DateTime.now();
    // DateTime.saturday == 6, DateTime.sunday == 7
    if (today.weekday == DateTime.saturday) {
      return Colors.blue; // 토요일이면 파란색
    } else if (today.weekday == DateTime.sunday) {
      return Colors.red; // 일요일이면 빨간색
    } else {
      return Theme.of(context).colorScheme.primaryContainer; // 평일이면 기존 색상
    }
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _onStateChange(bool showState) {
    if (_showTravelTime != showState) {
      setState(() {
        _showTravelTime = showState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleService = context.watch<ScheduleService>();
    final l10n = AppLocalizations.of(context);

    // _showTravelTime 상태에 따라 scheduleService.schedules를 필터링
    final List<Schedule> allSchedules = scheduleService.schedules;
    final List<Schedule> filteredSchedules;

    if (_showTravelTime) {
      filteredSchedules = allSchedules; // 스위치가 켜져 있으면 모든 일정 표시
    } else {
      // 스위치가 꺼져 있으면 scheduleId가 -1이 아닌 일정만 필터링
      filteredSchedules =
          allSchedules.where((s) => s.scheduleId != -1).toList();
    }

    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar(
            currentState: _showTravelTime,
            onStateChanged: _onStateChange,
          ),

          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SfCalendar(
                    view: CalendarView.week,
                    controller: _calendarController,
                    dataSource: ScheduleDataSource(filteredSchedules),

                    backgroundColor: Theme.of(context).colorScheme.surface,

                    headerHeight: 40, // 헤더의 높이를 지정. 이 속성을 0으로 설정하여 헤더 영역을 숨김
                    headerStyle: CalendarHeaderStyle(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      textAlign: TextAlign.left,
                      textStyle: TextStyle(
                        // 텍스트 스타일 지정
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    appointmentBuilder: (
                      BuildContext context,
                      CalendarAppointmentDetails details,
                    ) {
                      final appointment = details.appointments.first;

                      // ScheduleService에서 appointment와 일치하는 원본 Schedule 객체를 찾는다.
                      final Schedule? schedule = scheduleService
                          .findScheduleByAppointment(appointment);

                      // ✅ 4. '이동 시간' (scheduleId == -1)인지 확인
                      if (schedule?.scheduleId == -1) {
                        // --- '이동 시간'일 경우 특별한 UI 반환 ---
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            // 반투명한 회색 배경
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                            // 점선 테두리 (시각적 구분)
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_walk,
                                color: Colors.white,
                                size: 24,
                              ), // 이동 아이콘
                              const SizedBox(width: 4),
                              // Expanded(
                              //   child: Text(
                              //     schedule!.title, // "이동 시간" 또는 "A -> B"
                              //     style: const TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 10,
                              //       fontStyle: FontStyle.italic,
                              //     ),
                              //     overflow: TextOverflow.ellipsis,
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      }
                      // ✅ 6. '일반 일정'일 경우의 UI
                      else {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: const EdgeInsets.all(4),
                          color: hexToColor(
                            schedule!.color ?? '#3366FF',
                          ), // 일정 고유 색상
                          child: Text(
                            schedule.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                    },

                    showDatePickerButton: true,
                    firstDayOfWeek: 1,
                    allowDragAndDrop: false,
                    viewHeaderStyle: ViewHeaderStyle(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    todayHighlightColor:
                        _getTodayHighlightColor(), //Color(0xEE265A3A),
                    todayTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    selectionDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      shape: BoxShape.rectangle,
                    ),

                    timeSlotViewSettings: TimeSlotViewSettings(
                      startHour: 6,
                      endHour: 24,
                      timeIntervalHeight: 70,
                      timeFormat: 'HH:mm',
                    ),

                    onLongPress: (details) {
                      if (details.appointments != null &&
                          details.appointments!.isNotEmpty) {
                        // SfCalendar에서 탭한 appointment 객체를 가져온다.
                        // appointment class의 객체이기 때문에, Schedule 타입으로 변환하여 원본 스케줄을 찾아 수정해야 한다.
                        final appointment = details.appointments!.first;

                        final authService =
                            context
                                .read<
                                  AuthService
                                >(); // 일정을 추가하는데 userId를 가져오기 위함
                        final userId = authService.currentUser!.userId;

                        // ScheduleService에서 appointment와 일치하는 원본 Schedule 객체를 찾는다.
                        final Schedule? originalSchedule = scheduleService
                            .findScheduleByAppointment(appointment);

                        // 만약 일치하는 Schedule 객체를 찾지 못했다면 아무것도 하지 않음
                        if (originalSchedule == null) {
                          print("Error: 원본 Schedule 객체를 찾을 수 없습니다.");
                          return;
                        }

                        // TODO : 여기에 상세 정보를 출력할 BottomSheet를 출력.
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder:
                              (_) => ScheduleDetailSheet(
                                appointment: appointment,
                                onEdit: () async {
                                  Navigator.pop(context); // 상세 시트 닫기

                                  // 원본 Schedule 객체를 수정 페이지에 전달한다.
                                  final editedResult = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddSchedulePage(
                                            rootContext: context,
                                            // 기존 Schedule을 전달해야 함.
                                            initialSchedule:
                                                originalSchedule, // 원본 스케줄 객체를 전달.
                                          ),
                                    ),
                                  );

                                  //수정이 성공적으로 완료되었다면 (true가 반환되면) Toast 알림을 띄웁니다.
                                  if (editedResult == true) {
                                    if (!context.mounted) return;
                                    toastification.show(
                                      context: context,
                                      type: ToastificationType.success,
                                      style: ToastificationStyle.flatColored,
                                      autoCloseDuration: const Duration(
                                        seconds: 3,
                                      ),
                                      title: const Text('일정이 성공적으로 수정되었습니다.'),
                                    );

                                    // 일정 목록 새로고침
                                    _loadSchedules();
                                  }
                                },
                                // 삭제 로직
                                onDelete: () async {
                                  // TODO : Dialog를 띄워 정말로 일정을 삭제할 것인지 묻고, 확인 버튼이 눌리면 그때 일정 삭제 후 시트를 닫는걸로.
                                  bool deleteDesided =
                                      false; // 일정 삭제 여부를 저장하는 bool 변수

                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('일정 삭제'),
                                        content: Text('해당 일정을 정말 삭제하시겠습니까?'),
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
                                      "삭제하기로 한 $userId의 스케쥴 ID : ${originalSchedule.scheduleId!}",
                                    );

                                    // 삭제하기를 결정하였다면 여기에서 deleteSchedule() 함수 실행.
                                    bool deletedResult = await scheduleService
                                        .deleteSchedule(
                                          userId,
                                          originalSchedule.scheduleId!,
                                        );

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
                                        title: const Text('일정이 성공적으로 삭제되었습니다.'),
                                      );

                                      _loadSchedules();
                                    }
                                  }

                                  Navigator.pop(context); // 시트 닫기
                                },
                              ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          floatingActionButton: SpeedDial(
            icon: Icons.add,
            activeIcon: Icons.close,
            backgroundColor: Theme.of(context).colorScheme.primary, // 버튼 배경색
            foregroundColor:
                Theme.of(context).colorScheme.onPrimary, // 버튼 내부의 아이콘 색

            children: [
              SpeedDialChild(
                child: Icon(Icons.calendar_today),
                label: context.l10n.linkEverytime,
                onTap: () async {
                  // 에브리타임 연동 창으로 이동, 일정 추가 결과에 따른 결과를 반환받음.
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (pageContext) =>
                              EverytimeLinkPage(rootContext: context),
                    ),
                  );
                },
              ),

              SpeedDialChild(
                child: Icon(Icons.calendar_today),
                label: context.l10n.addSchedule,
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

                    // TODO : 라이트모드, 다크모드 구분하기
                    toastification.show(
                      context:
                          context, // optional if you use ToastificationWrapper
                      type: ToastificationType.success,
                      style: ToastificationStyle.flatColored,
                      autoCloseDuration: const Duration(seconds: 3),
                      title: Text('제하하하하하!! 일정을 등록했다!!'),
                    );

                    _loadSchedules();
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
            child: Center(
              // TODO : 챗봇에서 사용했던 로딩 연출로 변경
              child: SpinKitFadingCube(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// 상단의 AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool currentState; // 현재 TravelTime의 표시 여부
  final Function(bool) onStateChanged;

  const CustomAppBar({
    super.key,
    required this.currentState,
    required this.onStateChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _buildFormatButton(
    BuildContext context,
    bool State,
    String text,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onStateChanged(State),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. 현재 테마의 밝기를 확인합니다.
    final brightness = Theme.of(context).brightness;

    // ✅ 2. 밝기에 따라 사용할 로고 이미지 경로를 결정합니다.
    final String logoPath =
        (brightness == Brightness.dark)
            ? 'assets/images/logo_dark.png' // 다크 모드일 때 (배경이 어두울 때)
            : 'assets/images/logo.png'; // 라이트 모드일 때 (배경이 밝을 때)

    // final String yearMonthText = DateFormat(
    //   'yyyy년 MM월',
    // ).format(widget.currentDate);
    return AppBar(
      automaticallyImplyLeading: false, // 강제로 뒤로가기 버튼 제거
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽 : 앱 로고
          Image.asset(logoPath, height: 45),

          // 오른쪽 : 도움말 아이콘
          Row(
            children: [
              Text(context.l10n.distance, style: TextStyle(fontSize: 14)),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFormatButton(
                      context,
                      true,
                      "ON",
                      currentState == true,
                    ),
                    _buildFormatButton(
                      context,
                      false,
                      "OFF",
                      currentState == false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
