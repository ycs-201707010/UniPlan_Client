import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/subject_model.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:all_new_uniplan/models/timetable_model.dart';

class EverytimeService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  final ScheduleService _scheduleService;
  EverytimeService(this._scheduleService);

  final List<Timetable> _currentTimetableList = [];
  List<Timetable>? get currentTimetableList => _currentTimetableList;

  // UI에 표시되는 시간표를 currentTimetable로 지정
  Timetable? _currentTimetable;
  Timetable? get currentTimetable => _currentTimetable;

  // DB로 부터 등록되어 있
  // Future<void> getEverytimeScheduleFromDB() {}

  // 에브리타임 시간표 링크를 통해 정보를 크롤링하여 가져오는 메서드
  Future<void> getEverytimeSchedule(String everytimeUrl) async {
    final Map<String, dynamic> body = {"url": everytimeUrl};
    _currentTimetable = Timetable();
    try {
      final response = await _apiClient.post('/everytime', body: body);
      var json = jsonDecode(response.body);
      var message = json['message'];

      // 입력받은 기간에 존재하는 요일 갯수 만큼 생성하고 currentTimetable에 추가
      if (message == "Get Timetable Successed") {
        var scheduleJsonList = json['output'] as List<dynamic>;
        // 시간표 정보가 나열된 jsonList을 순회
        for (var scheduleJson in scheduleJsonList) {
          // print(scheduleJson);

          var subject = Subject.fromJson(scheduleJson);
          currentTimetable!.addSubjectToList(subject);
        }
        _currentTimetableList.add(_currentTimetable!);
      } else {
        throw Exception('Get Timetable Failed: $message');
      }
    } catch (e) {
      print('에브리타임 시간표 정보를 가져오는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  void setTimetableDate(DateTime startDate, DateTime endDate) async {
    _currentTimetable!.setPeriod(startDate, endDate);
  }

  // 시간표 정보들을 가져오는 메서드
  Future<void> getTimetable(int userId) async {
    final Map<String, dynamic> body = {"user_id": userId};

    try {
      final response = await _apiClient.post(
        '/everytime/getTimetable',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Get Timetable Successed") {
        //
      } else {
        throw Exception('Get Timetable Faield: $message');
      }
    } catch (e) {
      print('시간표 정보를 가져오는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 시간표에 존재하는 수업 정보들을 가져오는 메서드
  Future<void> getTimetableSubject(int userId) async {
    final Map<String, dynamic> body = {"user_id": userId};

    try {
      final response = await _apiClient.post(
        '/everytime/getTimetableSubject',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Get TimetableSubject Successed") {
        //
      } else {
        throw Exception('Get TimetableSubject Faield: $message');
      }
    } catch (e) {
      print('시간표의 수업 정보를 가져오는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 시간표 정보를 저장하는 테이블을 DB에 생성하도록 요청하는 메서드
  Future<void> addTimetable(int userId, String title) async {
    final Map<String, dynamic> body = {"user_id": userId, "title": title};

    try {
      final response = await _apiClient.post(
        '/everytime/addTimetable',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Add Timetable Successed") {
        var result = json['result'];

        int tableId = result["class_id"] as int;
        _currentTimetable!.tableId = tableId;
      } else {
        throw Exception('Add Timetable Faield: $message');
      }
    } catch (e) {
      print('시간표를 생성하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 현재 시간표를 각 주마다의 개별 일정으로 DB에 추가하는 메서드
  Future<void> addTimetableSchedule(
    int userId,
    String title,
    DateTime startDate,
    DateTime endDate,
  ) async {
    setTimetableDate(startDate, endDate);
    await addTimetable(userId, title);
    for (final subject in _currentTimetable!.subjects!) {
      final startDate = _currentTimetable!.findNextWeekday(
        _currentTimetable!.startDate!,
        subject.day,
      );
      final String formattedDate = DateFormat('yyyy-MM-dd').format(startDate);

      final String formattedStartTime =
          '${subject.startTime.hour.toString().padLeft(2, '0')}:${subject.startTime.minute.toString().padLeft(2, '0')}:00';
      final String formattedEndTime =
          '${subject.endTime.hour.toString().padLeft(2, '0')}:${subject.endTime.minute.toString().padLeft(2, '0')}:00';

      final String memo = [subject.professor, subject.classroom]
          .where((s) => s != null && s.isNotEmpty) // null이 아니고 비어있지 않은 항목만 필터링
          .join(' - '); // 필터링된 항목들을 ' - '로 연결

      final repeat = _currentTimetable!.getRepeatCount(subject.day);

      final Map<String, dynamic> body = {
        'user_id': userId,
        'title': subject.title,
        'date': formattedDate,
        'start_time': formattedStartTime,
        'end_time': formattedEndTime,
        if (_currentTimetable!.location != null)
          'location': _currentTimetable!.location,
        if (memo.isNotEmpty) 'memo': memo,
        'repeat_count': repeat,
      };

      try {
        final response = await _apiClient.post(
          '/everytime/addEverytimeSchedule',
          body: body,
        );
        var json = jsonDecode(response.body);
        var message = json['message'];

        if (message == "Add Schedule Successed") {
          var result = json['result'];
          print(result);

          var scheduleJsonList = result["schedules"] as List<dynamic>;

          // 충돌이 발생한 date를 통해 충돌된 일정을 _currentTimeTable.conflict~ 에 추가
          // final schedule = Schedule(scheduleId: scheduleId, title: title, date: date, startTime: startTime, endTime: endTime)

          for (final scheduleJson in scheduleJsonList) {
            final schedule = Schedule.fromJson(
              scheduleJson as Map<String, dynamic>,
            );
            _scheduleService.addScheduleToList(schedule);
          }
        }
        // else if(

        // )
      } catch (e) {
        print('시간표 정보를 저장하는 과정에서 에러 발생: $e');
        // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
        rethrow;
      }
    }
  }
  // void checkConflict(Schedule timetableSchedule) {
  //   if (currentTimetable != null) {
  //     // 매개변수로 전달받은 시간표의 개별 일정과 같은 날에 위치한 기존 일정들을 찾음
  //     List<Schedule> schedules = _scheduleService.findSchedulesAtDate(
  //       timetableSchedule.date,
  //     );

  //     // 시간표 일정과 같은 날에 위치한 기존 일정이 없다면
  //     if (schedules.length == 0) {
  //       _currentTimetableSchedule!.add(timetableSchedule);
  //       _nonConflictingSchedules!.add(timetableSchedule);
  //     }
  //     // 시간표 일정과 같은 날에 위치한 기존 일정이 있다면
  //     else {
  //       // 일정의 기간(시작 시간 ~ 종료 시간)과 시간표의 기간을 비교하여 중복을 확인
  //       // 시간표의 일정과 같은 날에 위치한 일정들을 순회하며 조건을 통해 같은 요일에서도 같은 시간대에 위치한 지에 대한 중복 확인
  //       for (final schedule in schedules) {
  //         // 시간대가 중복되는 경우
  //         if (schedule.startTime.isBefore(timetableSchedule.endTime) &&
  //             schedule.endTime.isAfter(timetableSchedule.startTime)) {
  //           final conflicSchedule = ScheduleConflict(
  //             timeTableSchedule: timetableSchedule,
  //             existingSchedule: schedule,
  //           );
  //           _conflictingSchedules.add(conflicSchedule);
  //         }
  //         // 시간대가 중복되지 않는 경우
  //         else {
  //           _currentTimetableSchedule!.add(timetableSchedule);
  //           _nonConflictingSchedules!.add(timetableSchedule);
  //           // 사용자에게 해당 시간표를 일정에 추가할 건지 여부를 물어봄
  //           // 만약 예 버튼을 클릭한 경우 일정을 추가하는 메서드를 호출
  //         }
  //       }
  //     }
  //   }
  // }

  // void modifyConflict(Schedule newSchedule, Schedule modifySchedule) {
  //   // 변경하는 일정이 캘린더의 존재하던 기존 일정인 경우
  //   if (modifySchedule == _conflictingSchedules.first.existingSchedule) {
  //   }
  //   // 변경하는 일정이 시간표의 일정인 경우
  //   else if (modifySchedule == _conflictingSchedules.first.timeTableSchedule) {
  //     // currentTimeTableScheudle의 요소에서 해당 부분을 변경
  //   }
  //   // 둘 다 아닌 경우
  //   else {
  //     return;
  //   }
  //   _conflictingSchedules.removeAt(0);
  // }

  // 연쇄적으로 충돌을 일으키는 일정은 앞선 일정을 변경하면 변경 사항을 반영해야 하기 때문에
  // 이를 수행하는 메서드
  // void findChainSchedule() {}
}
