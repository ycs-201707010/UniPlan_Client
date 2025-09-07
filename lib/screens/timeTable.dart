// ** 대학 시간표 페이지 **

import 'package:all_new_uniplan/models/subject_model.dart';
import 'package:all_new_uniplan/screens/everytime_link_page.dart';
import 'package:all_new_uniplan/services/everytime_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:timetable_view/timetable_view.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final List<LaneEvents> _subjects = []; // LaneEvents를 저장할 리스트

  // ** LaneEvents 내부에 삽입될 TableEvent를 요일별로 저장함 **
  final List<Map<String, dynamic>> _tableEvents = [
    {'day': '월', 'list': <TableEvent>[]},
    {'day': '화', 'list': <TableEvent>[]},
    {'day': '수', 'list': <TableEvent>[]},
    {'day': '목', 'list': <TableEvent>[]},
    {'day': '금', 'list': <TableEvent>[]},
  ];

  @override
  Widget build(BuildContext context) {
    final everytimeService = context.watch<EverytimeService>();

    return Scaffold(
      appBar: AppBar(title: Text('내 시간표')),
      body: TimetableView(
        // 시간표에 들어갈 요일별 강의 데이터 생성
        laneEventsList: _subjects,
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
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => EverytimeLinkPage()),
              );

              if (result == true) {
                final currentSubjects =
                    everytimeService.currentTimetable!.subjects!;

                int dayIndex = 0;

                setState(() {
                  // TODO : 실제 과목을 추가할 수 있도록 서버 단 코드와 연결하기
                  _subjects.clear();

                  _tableEvents[0]['list'].clear();
                  _tableEvents[1]['list'].clear();
                  _tableEvents[2]['list'].clear();
                  _tableEvents[3]['list'].clear();
                  _tableEvents[4]['list'].clear();

                  for (int i = 0; i < currentSubjects.length; i++) {
                    switch (weekdayISMap[currentSubjects[i].day]) {
                      case '월':
                        dayIndex = 0;
                        break;
                      case '화':
                        dayIndex = 1;
                        break;
                      case '수':
                        dayIndex = 2;
                        break;
                      case '목':
                        dayIndex = 3;
                        break;
                      case '금':
                        dayIndex = 4;
                        break;
                    }

                    _tableEvents[dayIndex]['list'].add(
                      TableEvent(
                        title:
                            '${currentSubjects[i].title} \n\n ${currentSubjects[i].classroom}',
                        eventId: dayIndex + (i * 12),
                        startTime: TableEventTime(
                          hour: currentSubjects[i].startTime.hour,
                          minute: currentSubjects[i].startTime.minute,
                        ),
                        endTime: TableEventTime(
                          hour: currentSubjects[i].endTime.hour,
                          minute: currentSubjects[i].endTime.minute,
                        ),
                        laneIndex: dayIndex, // 월요일
                        backgroundColor: Colors.deepOrangeAccent,
                        textStyle: TextStyle(fontSize: 12),
                      ),
                    );
                  }

                  for (int i = 0; i < _tableEvents.length; i++) {
                    _subjects.add(
                      LaneEvents(
                        lane: Lane(name: _tableEvents[i]['day'], laneIndex: i),
                        events: _tableEvents[i]['list'],
                      ),
                    );
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // 각 요일별 강의 데이터를 생성하는 함수
  List<LaneEvents> _buildLaneEvents() {
    // TODO : 현재 사용자 DB에 저장된 과목을 불러와 LaneEvents 배열로 반환할 수 있도록

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
