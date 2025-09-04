import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:all_new_uniplan/screens/location_picker_page.dart';

class ScheduleService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  final List<Schedule> _schedules = [];

  List<Schedule> get schedules => _schedules;

  // 메서드가 실행되고 있음을 나타내는 필드
  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 서버에 user_id를 통해 DB를 검색하여 일정 정보를 가져와 ScheduleService의 List 타입 필드에 추가하고
  // 상태 변화를 알리는 메서드
  Future<void> getSchedule(int userId) async {
    final Map<String, dynamic> body = {"user_id": userId};

    try {
      final response = await _apiClient.post(
        '/schedule/getSchedule',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Get Schedule Successed") {
        var schedulesJson = json["schedule"];
        updateScheduleListFromJson(schedulesJson);

        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
        notifyListeners();
      } else if (message == 'Get Schedule Empty') {
        return;
      } else {
        throw Exception('Get Schedule Failed: $message');
      }
    } catch (e) {
      print('일정을 검색하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 유저의 일정 DB에 일정을 추가하고 저장될 때 생성되는 schedule_id를 반환받아
  // Schedule에 부여하여 ScheduleService의 List에 추가하는 메서드
  Future<void> addSchedule(
    int userId,
    String title,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime, {
    String? location,
    String? memo,
    bool? isLongProject,
  }) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'title': title,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      if (location != null) 'location': location,
      if (memo != null) 'memo': memo,
      if (isLongProject != null) 'long_project': isLongProject,
    };

    try {
      final response = await _apiClient.post(
        '/schedule/addSchedule',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Add Schedule Successed") {
        int scheduleId = json["schedule"] as int;
        int? projectId;

        if (isLongProject == true) {
          // projectId = json["project_id"] as int;
        }

        Schedule newSchedule = Schedule(
          schedule_id: scheduleId,
          title: title,
          date: date,
          startTime: startTime,
          endTime: endTime,
          location: location,
          memo: memo,
          isLongProject: isLongProject,
          projectId: projectId,
        );

        addScheduleToList(newSchedule);

        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
        notifyListeners();
      } else {
        throw Exception('Get Schedule Failed: $message');
      }
    } catch (e) {
      print('일정을 검색하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 일정을 DB 상에서 변경하고
  Future<void> modifySchedule(
    int userId,
    Schedule originalSchedule,
    Schedule modifySchedule,
  ) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'add_schedule': originalSchedule.toJson(),
      'delete_schedule': modifySchedule.toJson(),
    };

    body['add_schedule']['user_id'] = userId;
    body['delete_schedule']['user_id'] = userId;

    try {
      final response = await _apiClient.post(
        '/schedule/modifySchedule',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Modify Schedule Successed") {
        int scheduleId = json['schedule_id'] as int;
        Schedule newSchedule = modifySchedule.copyWith(schedule_id: scheduleId);

        modifyScheduleToList(originalSchedule, newSchedule);

        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
        notifyListeners();
      } else {
        throw Exception('Get Schedule Failed: $message');
      }
    } catch (e) {
      print('일정을 검색하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  void updateScheduleListFromJson(dynamic schedulesJson) {
    // 기존 목록을 비움
    _schedules.clear();
    final scheduleMap = schedulesJson as Map;
    // 맵을 반복하며 모델의 fromJson 생성자를 사용
    scheduleMap.forEach((key, value) {
      final schedule = Schedule.fromJson(value as Map<String, dynamic>);
      _schedules.add(schedule);
    });

    // UI에 변경사항 알림
    notifyListeners();
  }

  void addScheduleToList(Schedule schedule) {
    _schedules.add(schedule);
    notifyListeners();

    print('[Client log] : 챗봇을 통해 스케줄 입력');
  }

  void modifyScheduleToList(
    Schedule originalSchedule,
    Schedule modifySchedule,
  ) {
    final index = _schedules.indexWhere(
      (s) =>
          s.title == originalSchedule.title &&
          s.startTime == originalSchedule.startTime &&
          s.endTime == originalSchedule.endTime,
    );
    if (index != -1) {
      _schedules[index] = modifySchedule;
    }
    notifyListeners();

    print('[Client log] : 챗봇을 통해 스케줄 수정');
  }

  void removeScheduleByAppointment(Appointment appointment) {
    _schedules.removeWhere(
      (s) =>
          s.title == appointment.subject &&
          s.startTime.hour == appointment.startTime.hour &&
          s.startTime.minute == appointment.startTime.minute,
    );

    // UI 갱신을 위해 notifyListeners() 호출
    notifyListeners();
  }
}
