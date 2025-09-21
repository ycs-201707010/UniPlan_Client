import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('프로젝트를 불러오는 데 실패했습니다: $e')));
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
                                  : Colors.black,
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

            Container(
              margin: EdgeInsets.only(left: 15),
              child: Text(
                '등록된 과목을 다수 불러와\n시간표에 저장할 수 있습니다.',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ); // Scaffold로 변경
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
