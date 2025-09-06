import 'package:all_new_uniplan/screens/everytime_link_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:timetable_view/timetable_view.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('내 시간표')),
      body: TimetableView(
        // 시간표에 들어갈 요일별 강의 데이터 생성
        laneEventsList: _buildLaneEvents(),
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
            label: 'Add Schedule',
            onTap: () async {
              // 일정 추가 다이얼로그 열기 -> 일정 추가 창으로 이동하는 로직으로 변경 필요!
              // final newSchedule = await Navigator.push<Schedule>(
              //   context,
              //   MaterialPageRoute(
              //     builder:
              //         (pageContext) => AddSchedulePage(rootContext: context),
              //   ),
              // );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EverytimeLinkPage(),
                ),
              );

              setState(() {
                // TODO : 실제 과목을 추가할 수 있도록 서버 단 코드와 연결하기
              });
            },
          ),
        ],
      ),
    );
  }

  // 각 요일별 강의 데이터를 생성하는 함수
  List<LaneEvents> _buildLaneEvents() {
    return [
      // 월요일
      LaneEvents(
        lane: Lane(name: '월', laneIndex: 0),
        events: [
          TableEvent(
            title: '객체지향프로그래밍',
            eventId: 1,
            startTime: TableEventTime(hour: 10, minute: 0),
            endTime: TableEventTime(hour: 11, minute: 30),
            laneIndex: 0, // 월요일
            backgroundColor: Colors.blue.shade200,
            textStyle: TextStyle(fontSize: 12),
          ),
          TableEvent(
            title: '이산수학',
            eventId: 2,
            startTime: TableEventTime(hour: 14, minute: 0),
            endTime: TableEventTime(hour: 15, minute: 50),
            laneIndex: 0,
            backgroundColor: Colors.green.shade200,
          ),
        ],
      ),
      // 화요일
      LaneEvents(
        lane: Lane(name: '화', laneIndex: 1),
        events: [
          TableEvent(
            title: '자료구조',
            eventId: 11,
            startTime: TableEventTime(hour: 11, minute: 0),
            endTime: TableEventTime(hour: 12, minute: 30),
            laneIndex: 1, // 화요일
            backgroundColor: Colors.orange.shade200,
          ),
        ],
      ),
      // 수요일
      LaneEvents(
        lane: Lane(name: '수', laneIndex: 2),
        events: [], // 강의 없는 날
      ),
      // 목요일
      LaneEvents(
        lane: Lane(name: '목', laneIndex: 3),
        events: [
          TableEvent(
            title: '자료구조',
            eventId: 31,
            startTime: TableEventTime(hour: 11, minute: 0),
            endTime: TableEventTime(hour: 12, minute: 30),
            laneIndex: 3, // 목요일
            backgroundColor: Colors.orange.shade200,
          ),
        ],
      ),
      // 금요일
      LaneEvents(
        lane: Lane(name: '금', laneIndex: 4),
        events: [
          TableEvent(
            title: '컴퓨터 구조',
            eventId: 41,
            startTime: TableEventTime(hour: 9, minute: 30),
            endTime: TableEventTime(hour: 11, minute: 20),
            laneIndex: 4, // 금요일
            backgroundColor: Colors.purple.shade200,
          ),
        ],
      ),
    ];
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
