import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:timetable_view/timetable_view.dart';
import 'package:intl/intl.dart';

import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/subject_model.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:all_new_uniplan/models/timetable_model.dart';

class ScheduleConflict {
  final Schedule existingSchedule;
  final Schedule timetableSchedule;

  ScheduleConflict({
    required this.existingSchedule,
    required this.timetableSchedule,
  });
}

class EverytimeService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  final ScheduleService _scheduleService;
  EverytimeService(this._scheduleService);

  List<Timetable>? _currentTimetableList = [];
  List<Timetable>? get currentTimetableList => _currentTimetableList;

  // UI에 표시되는 시간표를 currentTimetable로 지정
  Timetable? _currentTimetable;
  Timetable? get currentTimetable => _currentTimetable;

  // 시간표의 반복 일정을 생성하는 과정에서 충돌/비충돌 일정을 각각 저장하는 필드
  final List<ScheduleConflict> _conflictingSchedules = [];
  List<ScheduleConflict>? get conflictingSchedules => _conflictingSchedules;

  bool _isLoading = false; // 로딩 상태 추가
  bool get isLoading => _isLoading;

  // 에브리타임 시간표 링크를 통해 정보를 크롤링하여 가져오는 메서드
  Future<void> getEverytimeSchedule(String everytimeUrl) async {
    _isLoading = true;
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
          var subject = Subject.fromCrawlJson(scheduleJson);
          _currentTimetable!.addSubjectToList(subject);
        }
        _currentTimetableList!.add(_currentTimetable!);
      } else {
        throw Exception('Get Timetable Failed: $message');
      }
    } catch (e) {
      print('에브리타임 시간표 정보를 가져오는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  void setTimetableDate(DateTime startDate, DateTime endDate) async {
    _currentTimetable!.setPeriod(startDate, endDate);
  }

  // 시간표 정보들을 가져오는 메서드
  Future<void> getTimetable(int userId) async {
    _isLoading = true; // 로딩 시작
    notifyListeners();
    final Map<String, dynamic> body = {"user_id": userId};
    List<Timetable> newTimetableList = [];

    try {
      final response = await _apiClient.post(
        '/everytime/getTimetable',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Get Timetable Successed") {
        List<Future<Timetable>> timetableFutures = [];

        var timetableJsonList = json['result'] as List<dynamic>;

        for (final timetableJson in timetableJsonList) {
          final baseTimetable = Timetable.fromJson(
            timetableJson as Map<String, dynamic>,
          );

          final future = Future(() async {
            if (baseTimetable.tableId != null) {
              // ✅ getTimetableSubject 호출하고 결과를 받음
              final subjects = await getTimetableSubject(
                baseTimetable.tableId!,
              );
              // ✅ copyWith를 사용해 subjects가 추가된 '새로운' Timetable 객체 반환
              return baseTimetable.copyWith(subjects: subjects);
            } else {
              return baseTimetable; // ID 없으면 그대로 반환
            }
          });
          timetableFutures.add(future);
        }

        // ✅ 모든 시간표+수업 정보 가져오기 작업을 동시에 실행하고 기다림
        newTimetableList = await Future.wait(timetableFutures);

        // ✅ 모든 작업이 완료된 후, 상태 변수를 '한 번에' 교체
        _currentTimetableList = newTimetableList;
        _currentTimetable =
            _currentTimetableList!.isNotEmpty
                ? _currentTimetableList!.first
                : null;
      } else {
        throw Exception('Get Timetable Failed: $message');
      }
    } catch (e) {
      print('시간표 정보를 가져오는 과정에서 에러 발생: $e');
      _currentTimetableList = []; // 에러 시 초기화
      _currentTimetable = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners(); // 최종 상태 알림
    }
  }

  // 시간표에 존재하는 수업 정보들을 가져오는 메서드
  Future<List<Subject>> getTimetableSubject(int classId) async {
    final Map<String, dynamic> body = {"class_id": classId};
    List<Subject> subjects = [];

    try {
      final response = await _apiClient.post(
        '/everytime/getTimetableSubject',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Get Timetable Subject Successed") {
        var subjectJsonList = json['result'] as List<dynamic>;
        if (subjectJsonList.isEmpty) {
          return [];
        }
        for (final subjectJson in subjectJsonList) {
          subjects.add(Subject.fromJson(subjectJson as Map<String, dynamic>));
        }
        return subjects;
      } else {
        throw Exception('Get Timetable Subject Failed: $message');
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
        _currentTimetable!.title = title;

        for (Subject subject in _currentTimetable!.subjects!) {
          addTimetableSubject(userId, tableId, subject);
        }
      } else {
        throw Exception('Add Timetable Faield: $message');
      }
    } catch (e) {
      print('시간표를 생성하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 시간표의 과목 정보를 저장하는 테이블을 DB에 생성하도록 요청하는 메서드
  Future<void> addTimetableSubject(
    int userId,
    int classId,
    Subject subject,
  ) async {
    final Map<String, dynamic> body = subject.toJson();
    body.addAll({"user_id": userId, "class_id": classId});
    try {
      final response = await _apiClient.post(
        '/everytime/addTimetableSubject',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Add Timetable Subject Successed") {
        int subjectId = json['lecture_id'] as int;
        subject.subjectId = subjectId;
      } else {
        throw Exception('Add Timetable Subject Faield: $message');
      }
    } catch (e) {
      print('시간표의 수업을 생성하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 현재 시간표를 각 주마다의 개별 일정으로 DB에 추가하는 메서드
  Future<void> addTimetableSchedule(
    int userId,
    String title, // Timetable 제목
    DateTime startDate,
    DateTime endDate,
  ) async {
    conflictingSchedules!.clear();
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

      final repeatCount = _currentTimetable!.getRepeatCount(subject.day);

      if (repeatCount == 0) {
        return;
      }

      final Map<String, dynamic> body = {
        'user_id': userId,
        'title': subject.title,
        'date': formattedDate,
        'start_time': formattedStartTime,
        'end_time': formattedEndTime,
        'fatigue_level': 1.8,
        if (_currentTimetable!.location != null)
          'location': _currentTimetable!.location,
        if (memo.isNotEmpty) 'memo': memo,
        'repeat_count': repeatCount,
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

          var createdCount = result["created_count"] as int;

          // 개별 일정이 생성되지 않은 경우

          var scheduleJsonList = result["schedules"] as List<dynamic>;

          if (scheduleJsonList.isNotEmpty) {
            for (final scheduleJson in scheduleJsonList) {
              final schedule = Schedule.fromJson(
                scheduleJson as Map<String, dynamic>,
              );
              _scheduleService.addScheduleToList(schedule);
              _currentTimetable!.generatedSchedules!.add(schedule);
            }
          }

          // 반복횟수와 일정 생성 개수가 같지 않은 경우
          // 기존 일정과 충돌이 발생한 것
          if (createdCount != repeatCount) {
            print("test1");
            var skippedDates = result["skipped_dates"] as List<dynamic>;

            // 충돌이 발생한 날짜 목록을 순회하며 충돌 일정 목록을 갱신
            for (final date in skippedDates) {
              final conflictDate = DateTime.parse(date as String);
              Schedule timetableSchedule = Schedule(
                title: subject.title,
                date: conflictDate,
                startTime: subject.startTime,
                endTime: subject.endTime,
                location: _currentTimetable!.location,
              );
              findConflict(timetableSchedule);
            }
          }
        } else {
          throw Exception('Add Schedule Faield: $message');
        }
      } catch (e) {
        print('시간표 정보를 저장하는 과정에서 에러 발생: $e');
        // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
        rethrow;
      }
    }
  }

  // 시간표의 제목을 수정하는 메서드
  Future<void> modifyTimetableTitle(
    int userId,
    int tableId,
    String title,
  ) async {
    final Map<String, dynamic> body = {
      "user_id": userId,
      "table_id": tableId,
      "title": title,
    };

    try {
      final response = await _apiClient.post(
        '/everytime/modifyTimetableTitle',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Modify Timetable Title Successed") {
        updateTimetableTitle(tableId, title);
      } else {
        throw Exception('Modify Timetable Title Failed: $message');
      }
    } catch (e) {
      print('시간표 정보를 가져오는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 추가하려는 시간표의 개별 일정과 충돌이 발생하는 캘린더에 등록된 기존 일정을 찾는 메서드
  void findConflict(Schedule timetableSchedule) async {
    // 충돌이 일어난 일정들을 찾음
    List<Schedule> schedules = await _scheduleService
        .findSchedulesAtDateAndTime(
          timetableSchedule.date,
          timetableSchedule.startTime,
          timetableSchedule.endTime,
        );

    for (final schedule in schedules) {
      final conflict = ScheduleConflict(
        existingSchedule: schedule,
        timetableSchedule: timetableSchedule,
      );
      _conflictingSchedules.add(conflict);
    }
  }

  // 지정한 tableId를 가지는 시간표를 찾는 메서드
  Timetable findTimetable(int tableId) {
    // _currentTimetableList에서 각 Timetable 인스턴스(s)의 tableId가
    // 메서드로 전달된 tableId와 일치하는 첫 번째 요소를 찾습니다.
    return _currentTimetableList!.firstWhere((s) => s.tableId == tableId);
  }

  void updateTimetableTitle(int tableId, String title) {
    _currentTimetableList!.firstWhere((s) => s.tableId == tableId).title =
        title;
    notifyListeners();
  }

  List<LaneEvents> buildLaneCurrentTimetableEventsList() {
    if (_currentTimetable == null ||
        _currentTimetable!.subjects == null ||
        _currentTimetable!.subjects!.isEmpty) {
      return [];
    }

    final Map<int, List<TableEvent>> eventsByDay = {};

    for (final subject in _currentTimetable!.subjects!) {
      final startTime = TableEventTime(
        hour: subject.startTime.hour,
        minute: subject.startTime.minute,
      );
      final endTime = TableEventTime(
        hour: subject.endTime.hour,
        minute: subject.endTime.minute,
      );

      // The 'day' field in Subject directly corresponds to the laneIndex (0=Mon, 1=Tue, ...)
      final dayIndex = subject.day;

      final tableEvent = TableEvent(
        title: subject.title,
        eventId: subject.subjectId!, // Use ID or hashCode
        startTime: startTime,
        endTime: endTime,
        laneIndex: dayIndex,
        backgroundColor: _getColorForSubject(
          subject.title,
        ), // Optional: assign color
        textStyle: const TextStyle(fontSize: 10, color: Colors.white),
      );

      // Add the event to the map, grouped by its day index
      (eventsByDay[dayIndex] ??= []).add(tableEvent);
    }

    // Create the final List<LaneEvents>
    final List<LaneEvents> laneEventsList = [];
    // Use weekdayISMap to get day names based on DateTime constants (1=Mon, ..., 7=Sun)
    // Assuming your subject.day matches the 0-6 index, not DateTime constants directly
    const List<String> dayNames = ['월', '화', '수', '목', '금', '토', '일'];
    for (int i = 0; i < 7; i++) {
      // Typically Mon-Fri (0-4) or Mon-Sun (0-6)
      laneEventsList.add(
        LaneEvents(
          lane: Lane(name: dayNames[i], laneIndex: i),
          events:
              eventsByDay[i + 1] ??
              [], // Get events for this day, or empty list if none
        ),
      );
    }

    // Return only lanes that typically appear in a timetable (e.g., Mon-Fri)
    return laneEventsList.sublist(0, 5); // Adjust if you need Sat/Sun
  }

  // Helper function to assign colors (optional)
  Color _getColorForSubject(String title) {
    final hash = title.hashCode;
    final index = hash % Colors.primaries.length;
    return Colors.primaries[index].shade300;
  }

  void deleteConflitFromList(ScheduleConflict conflict) {
    final bool removed = conflictingSchedules!.remove(conflict);

    // 2. 만약 제거되었다면 UI 갱신 알림
    if (removed) {
      notifyListeners();
    }
  }

  // 사용자가 드롭다운에서 다른 시간표를 선택했을 때 호출될 메서드
  void selectTimetable(Timetable timetable) {
    if (_currentTimetable != timetable) {
      _currentTimetable = timetable;

      notifyListeners(); // UI에 변경 알림
    }
  }

  void callNotifyListeners() {
    notifyListeners(); // UI에 변경 알림
  }
}
