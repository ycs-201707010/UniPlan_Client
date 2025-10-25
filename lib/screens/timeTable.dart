// ** 대학 시간표 페이지 **

import 'package:all_new_uniplan/models/subject_model.dart';
import 'package:all_new_uniplan/screens/everytime_link_page.dart';
import 'package:all_new_uniplan/services/everytime_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:timetable_view/timetable_view.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/models/timetable_model.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 첫 프레임이 그려진 다음에 데이터 로딩 시작
    // listen: false로 안전하게 서비스 접근
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = context.read<AuthService>();
      if (authService.isLoggedIn) {
        // initState에서 직접 호출
        context.read<EverytimeService>().getTimetable(
          authService.currentUser!.userId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final everytimeService = context.watch<EverytimeService>();

    // 현재 선택된 ID 가져오기 (null일 수 있음)
    final int? currentTableId = everytimeService.currentTimetable?.tableId;

    // 전체 시간표 목록 가져오기 (null일 수 있으므로 ?? [] 사용)
    final List<Timetable> allTimetables =
        everytimeService.currentTimetableList ?? [];

    // 현재 선택된 ID가 전체 목록에 '정확히 하나' 존재하는지 확인
    final bool isValueValid =
        currentTableId != null &&
        allTimetables.where((t) => t.tableId == currentTableId).length == 1;

    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<int?>(
          // 👇 유효한 경우에만 ID를 value로 설정하고, 아니면 null을 설정하여 오류 방지
          value: isValueValid ? currentTableId : null,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          underline: Container(height: 0),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          onChanged: (int? newTableId) {
            if (newTableId != null) {
              // ID를 사용하여 전체 리스트에서 해당 Timetable 객체를 찾음 (collection 패키지 사용 권장)
              final selectedTimetable = allTimetables.firstWhereOrNull(
                (t) => t.tableId == newTableId,
              );
              if (selectedTimetable != null) {
                everytimeService.selectTimetable(selectedTimetable);
              }
            }
          },
          items:
              allTimetables.map<DropdownMenuItem<int?>>((Timetable timetable) {
                return DropdownMenuItem<int?>(
                  value: timetable.tableId, // 고유 ID 사용
                  child: Text(timetable.title ?? '이름 없는 시간표'),
                );
              }).toList(),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body:
          everytimeService.isLoading
              ? const Center(child: CircularProgressIndicator()) // 로딩 중 UI
              : TimetableView(
                // 시간표에 들어갈 요일별 강의 데이터 생성
                laneEventsList:
                    everytimeService.buildLaneCurrentTimetableEventsList(),
                // 시간표 레이아웃 설정
                timetableStyle: TimetableStyle(
                  startHour: 9,
                  endHour: 18,
                  timeItemTextColor: Color(0xEE265A3A),
                  laneWidth: (MediaQuery.of(context).size.width / 6),
                  timeItemWidth: (MediaQuery.of(context).size.width / 6),
                ),

                // 강의를 클릭했을 때 실행될 함수
                onEventTap: onEventTapCallBack,
                // 빈 공간을 클릭했을 때 실행될 함수
                onEmptySlotTap: onTimeSlotTappedCallBack,
              ),

      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Color(0xEE265A3A), // 버튼 배경색
        foregroundColor: Colors.white, // 버튼 내부의 아이콘 색

        children: [
          SpeedDialChild(
            child: Icon(Icons.calendar_today),
            label: 'Link Everytime',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (pageContext) => EverytimeLinkPage(rootContext: context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void onEventTapCallBack(TableEvent event) {
    print(
      "Event Clicked!! LaneIndex ${event.laneIndex} Title: ${event.title} StartHour: ${event.startTime.hour} EndHour: ${event.endTime.hour}",
    );
  }

  void onTimeSlotTappedCallBack(
    int laneIndex,
    TableEventTime start,
    TableEventTime end,
  ) {
    print(
      "Empty Slot Clicked !! LaneIndex: $laneIndex StartHour: ${start.hour} EndHour: ${end.hour}",
    );
  }
}
