import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/schedule_model.dart'; // 사용자의 일정을 받아오는 클래스
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
  Future<bool> addSchedule(
    int userId,
    String title,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime, {
    String? location,
    String? memo,
    bool? isLongProject,
  }) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // 👇 2. TimeOfDay를 'HH:mm' 형식의 문자열로 변환
    final String formattedStartTime =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final String formattedEndTime =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    final Map<String, dynamic> body = {
      'user_id': userId,
      'title': title,
      'date': formattedDate,
      'start_time': formattedStartTime,
      'end_time': formattedEndTime,
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
        int scheduleId = json["schedule_id"] as int;
        int? projectId;

        if (isLongProject == true) {
          projectId = json["project_id"] as int;
        }

        Schedule newSchedule = Schedule(
          scheduleId: scheduleId,
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

        //성공 시 true 반환
        return true;
      } else {
        print('일정을 추가하는 과정에서 에러 발생: $message');
        // throw Exception('Get Schedule Failed: $message');
        return false;
      }
    } catch (e) {
      print('일정을 추가하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      // rethrow;
      return false;
    }
  }

  // 일정을 DB 상에서 변경하고
  // Future<void> modifySchedule(
  //   int userId,
  //   Schedule originalSchedule,
  //   Schedule modifySchedule,
  // ) async {
  //   //     final Map<String, dynamic> body = {
  //   //       'user_id': userId,
  //   //       'add_schedule': originalSchedule.toJson(),
  //   //       'delete_schedule': modifySchedule.toJson(),
  //   //     };

  //   //  body['delete_schedule']['schedule_id'] = modifySchedule.scheduleId;
  //   //     body['add_schedule']['user_id'] = userId;
  //   //     body['delete_schedule']['user_id'] = userId;

  //   final Map<String, dynamic> body = {
  //     'add_schedule': modifySchedule.toJson(),
  //     'delete_schedule': {
  //       'user_id': userId,
  //       'schedule_id': originalSchedule.scheduleId,
  //     },
  //   };

  //   body['add_schedule']['user_id'] = userId;

  //   try {
  //     final response = await _apiClient.post(
  //       '/schedule/modifySchedule',
  //       body: body,
  //     );

  //     var json = jsonDecode(response.body);
  //     var message = json['message'];

  //     if (message == "Modify Schedule Successed") {
  //       int scheduleId = json['schedule_id'] as int;
  //       Schedule newSchedule = modifySchedule.copyWith(scheduleId: scheduleId);

  //       modifyScheduleToList(originalSchedule, newSchedule);

  //       // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
  //       notifyListeners();
  //     } else {
  //       throw Exception('Get Schedule Failed: $message');
  //     }
  //   } catch (e) {
  //     print('일정을 검색하는 과정에서 에러 발생: $e');
  //     // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
  //     rethrow;
  //   }
  // }

  // 일정을 DB 상에서 변경하고
  Future<void> modifySchedule(
    int userId,
    Schedule originalSchedule,
    Schedule newSchedule,
  ) async {
    final Map<String, dynamic> body = {
      'add_schedule': newSchedule.toJson(),
      'delete_schedule': {
        'user_id': userId,
        'schedule_id': originalSchedule.scheduleId,
      },
    };

    body['add_schedule']['user_id'] = userId;

    print(body);
    try {
      final response = await _apiClient.post(
        '/schedule/modifySchedule',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Modify Schedule Successed") {
        int scheduleId = json['schedule_id'] as int;
        newSchedule = originalSchedule.copyWith(scheduleId: scheduleId);

        modifyScheduleToList(originalSchedule, newSchedule);

        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
        notifyListeners();
      } else {
        throw Exception('Get Schedule Failed: $message');
      }
    } catch (e) {
      print('일정을 수정하는 과정에서 에러 발생: $e');
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
