import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toastification/toastification.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  // ** 상태 변수 **
  bool _isLoading = true;
  CalendarFormat _calendarFormat =
      CalendarFormat.week; // 기본 뷰 : 주간. 토글 버튼으로 월간/주간 뷰 교체 가능
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  // TODO : 프로젝트를 불러오는 함수
  Future<void> _loadInitialData() async {
    final projectService = context.read<ProjectService>();
    final authService = context.read<AuthService>();

    try {
      // 사용자 ID로 모든 프로젝트와 하위 프로젝트 데이터를 불러옵니다.
      await projectService.getProjectByUserId(authService.currentUser!.userId);
    } catch (e) {
      if (mounted) {
        // todo : toastification로 변경
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(SnackBar(content: Text('프로젝트를 불러오는 데 실패했습니다: $e')));
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          title: const Text('프로젝트를 불러오는 데 실패했습니다'),
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

  // 뷰의 상태를 변경하는 함수.
  void _onFormatChange(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  // TODO : 리스트를 그리는 함수.
  void writeSubProjectList() {}

  @override
  Widget build(BuildContext context) {
    // watch를 사용하여 ProjectService의 데이터 변경을 감지
    final projectService = context.watch<ProjectService>();
    final projects = projectService.projects?.values.toList() ?? [];

    return Scaffold(
      // todo : Schedule 화면에서 쓴 appBar를 컴포넌트화 시켜서 여기서도 사용
      appBar: CustomAppBar(
        currentFormat: _calendarFormat,
        onFormatChanged: _onFormatChange,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              // 세로 스와이프를 막는 속성.
              availableGestures: AvailableGestures.horizontalSwipe,

              locale: 'ko_KR',
              firstDay: DateTime.utc(2025, 03, 01), // todo : 사용자의 계정 가입일로 변경??
              lastDay: DateTime.utc(2033, 12, 31),
              focusedDay: _focusedDay,

              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),

              daysOfWeekHeight: 35, // 일~토요일 표시줄의 세로 너비
              // 주간/월간 뷰 토글 기능
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },

              // 날짜 선택 기능
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // 선택된 날짜로 포커스 이동
                });
              },

              calendarBuilders: CalendarBuilders(
                // ✅ 1. 일반 날짜(평일, 주말)를 위한 빌더
                defaultBuilder: (context, day, focusedDay) {
                  // 일요일(7) 또는 토요일(6)인지 확인
                  if (day.weekday == DateTime.sunday ||
                      day.weekday == DateTime.saturday) {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color:
                              day.weekday == DateTime.sunday
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                      ),
                    );
                  }
                  // 평일은 기본 스타일을 사용하도록 null 반환
                  return null;
                },

                // ✅ 2. '오늘' 날짜가 주말일 경우를 위한 빌더
                todayBuilder: (context, day, focusedDay) {
                  // '오늘'을 표시하는 원형 데코레이션은 calendarStyle에서 처리되므로,
                  // 여기서는 텍스트 스타일만 지정합니다.
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              (day.weekday == DateTime.sunday)
                                  ? Colors.red
                                  : (day.weekday == DateTime.saturday)
                                  ? Colors.blue
                                  : Color(0xEE009425),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          // '오늘' 날짜가 주말이면 색상 적용, 아니면 기본 색상(흰색 등)
                          color:
                              (day.weekday == DateTime.sunday)
                                  ? Colors.red
                                  : (day.weekday == DateTime.saturday)
                                  ? Colors.blue
                                  : Colors.black,
                        ),
                      ),
                    ),
                  );
                },

                // ✅ 3. '선택된' 날짜가 주말일 경우를 위한 빌더
                selectedBuilder: (context, day, focusedDay) {
                  // '선택'을 표시하는 원형 데코레이션은 calendarStyle에서 처리되므로,
                  // 여기서는 텍스트 스타일만 지정합니다.
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (day.weekday == DateTime.sunday)
                                ? Colors.red
                                : (day.weekday == DateTime.saturday)
                                ? Colors.blue
                                : Color(0xEE009425),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          // '선택된' 날짜가 주말이면 색상 적용, 아니면 기본 색상(흰색 등)
                          color: Colors.white,
                          fontWeight: FontWeight.bold, // 선택된 날짜는 굵게
                        ),
                      ),
                    ),
                  );
                },

                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text('일', style: TextStyle(color: Colors.red)),
                    );
                  } else if (day.weekday == DateTime.saturday) {
                    return Center(
                      child: Text('토', style: TextStyle(color: Colors.blue)),
                    );
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 32),

            // Container(
            //   margin: EdgeInsets.only(left: 15),
            //   child: Text(
            //     '등록된 과목을 다수 불러와\n시간표에 저장할 수 있습니다.',
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontWeight: FontWeight.w600,
            //       fontSize: 16,
            //     ),
            //   ),
            // ),
            for (final project in projects)
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 프로젝트(카테고리) 제목 ---
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ), // 색상은 동적으로 변경 가능
                    ),
                    Divider(color: Colors.orange.shade300, thickness: 2),
                    const SizedBox(height: 8),

                    // --- 하위 프로젝트(목표) 목록 ---
                    if (project.subProjects != null &&
                        project.subProjects!.isNotEmpty)
                      for (final subProject in project.subProjects!)
                        ProjectProgressCard(
                          title: subProject.subGoal,
                          currentStep: subProject.done ?? 0,
                          maxStep:
                              subProject.maxDone ?? 1, // maxDone이 null이면 1로 처리
                        )
                    else
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('등록된 하위 목표가 없습니다.'),
                      ),
                  ],
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
            label: '세부 목표 짜기',
            onTap: () async {
              // 일정 추가 창으로 이동, 일정 추가 결과에 따른 결과를 반환받음.
              // final result = await Navigator.push<bool>(
              //   context,
              //   MaterialPageRoute(
              //     builder:
              //         (pageContext) =>
              //             AddSchedulePage(rootContext: context),
              //   ),
              // );

              // // TODO : 일정이 성공적으로 추가되었다면, 일정 추가창에서 캘린더 창으로 bool 형식의 응답을 하고, 일정 추가에 성공한 응답을 받으면 일정이 추가되었다는 Dialog 알림 주기
              // if (result == true) {
              //   // 성공했을 때 Toast 알림
              //   if (!context.mounted) return; // context 유효성 검사

              //   toastification.show(
              //     context:
              //         context, // optional if you use ToastificationWrapper
              //     type: ToastificationType.success,
              //     style: ToastificationStyle.flatColored,
              //     autoCloseDuration: const Duration(seconds: 3),
              //     title: Text('제하하하하하!! 일정을 등록했다!!'),
              //   );
              // }
            },
          ),

          SpeedDialChild(
            child: Icon(Icons.calendar_today),
            label: '프로젝트 생성',
            onTap: () async {
              // 일정 추가 창으로 이동, 일정 추가 결과에 따른 결과를 반환받음.
              // final result = await Navigator.push<bool>(
              //   context,
              //   MaterialPageRoute(
              //     builder:
              //         (pageContext) =>
              //             AddSchedulePage(rootContext: context),
              //   ),
              // );

              // // TODO : 일정이 성공적으로 추가되었다면, 일정 추가창에서 캘린더 창으로 bool 형식의 응답을 하고, 일정 추가에 성공한 응답을 받으면 일정이 추가되었다는 Dialog 알림 주기
              // if (result == true) {
              //   // 성공했을 때 Toast 알림
              //   if (!context.mounted) return; // context 유효성 검사

              //   toastification.show(
              //     context:
              //         context, // optional if you use ToastificationWrapper
              //     type: ToastificationType.success,
              //     style: ToastificationStyle.flatColored,
              //     autoCloseDuration: const Duration(seconds: 3),
              //     title: Text('제하하하하하!! 일정을 등록했다!!'),
              //   );
              // }
            },
          ),
        ],
      ),
    );
  }
}

// 상단의 AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ✅ 4. 부모로부터 받을 함수와 상태 변수를 선언합니다.
  final CalendarFormat currentFormat;
  final Function(CalendarFormat) onFormatChanged;

  const CustomAppBar({
    super.key,
    required this.currentFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/logo.png', height: 45),
          // 토글 버튼 컨테이너
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // '월' 버튼
                _buildFormatButton(
                  context,
                  CalendarFormat.month,
                  '월',
                  currentFormat == CalendarFormat.month,
                ),
                // '주' 버튼
                _buildFormatButton(
                  context,
                  CalendarFormat.week,
                  '주',
                  currentFormat == CalendarFormat.week,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 5. 버튼을 만드는 로직을 별도 함수로 분리하여 가독성 향상
  Widget _buildFormatButton(
    BuildContext context,
    CalendarFormat format,
    String text,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onFormatChanged(format), // ✅ 6. 전달받은 함수(콜백)를 호출
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProjectProgressCard extends StatelessWidget {
  final String title;
  final int currentStep;
  final int maxStep;

  const ProjectProgressCard({
    super.key,
    required this.title,
    required this.currentStep,
    required this.maxStep,
  });

  @override
  Widget build(BuildContext context) {
    // 진행률 계산 (0.0 ~ 1.0)
    final double progress = (maxStep == 0) ? 0.0 : currentStep / maxStep;
    final bool isCompleted = currentStep >= maxStep;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ 2. 목표 제목과 진행도 바 (대부분의 공간 차지)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ 3. 진행도 바
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.orange,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // ✅ 4. 진행률 텍스트와 아이콘
          Column(
            children: [
              Text(
                '$currentStep/$maxStep',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Icon(
                isCompleted ? Icons.check_circle : Icons.directions_run,
                color: isCompleted ? Colors.orange : Colors.black,
                size: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
