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

  // final List<Schedule> _currentPageScheudules = [];

  // 메서드가 실행되고 있음을 나타내는 필드
  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  int RecentScheudleIndex = 0;

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
        sortSchedulesByDate();

        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
        notifyListeners();
      } else if (message == 'Get Empty Schedule') {
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

  // 서버에 user_id를 통해 DB를 검색하여 일정 정보를 가져와 ScheduleService의 List 타입 필드에 추가하고
  // 상태 변화를 알리는 메서드
  Future<void> getScheduleByMonth(int year, int month, int userId) async {
    final Map<String, dynamic> body = {
      "user_id": userId,
      "year": year,
      "month": month,
    };

    try {
      final response = await _apiClient.post(
        '/schedule/getScheduleByMonth',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Get Schedule By Month Successed") {
        // TODO : 년, 월을 통해 불러온 스케줄 정보를 _currentPageSchedules에 추가하는 로직
        var schedulesJson = json["schedule"];

        updateScheduleListFromJson(schedulesJson);
        sortSchedulesByDate();

        // 상태 변경을 앱 전체에 알려 해당 클래스를 구독한 페이지에 영향을 준다
        notifyListeners();
      } else if (message == 'Get Schedule By Month Failed') {
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
    String? color,
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
      if (color != null) 'color': color,
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
          color: color,
        );

        addScheduleToList(newSchedule);
        sortSchedulesByDate();

        getFatigue(userId, scheduleId);

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
  Future<bool> modifySchedule(
    int userId,
    Schedule originalSchedule, // 기존 일정
    Schedule newSchedule, // 새 일정
  ) async {
    final Map<String, dynamic> body = {
      'add_schedule': newSchedule.toJson(),
      'delete_schedule': {
        'user_id': userId,
        'schedule_id': originalSchedule.scheduleId,
      },
    };

    body['add_schedule']['user_id'] = userId;

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

        getFatigue(userId, scheduleId);
        //성공 시 true 반환
        return true;
      } else {
        print('일정을 수정하는 과정에서 에러 발생: $message');
        // throw Exception('Modify Schedule Failed: $message');
        return false;
      }
    } catch (e) {
      print('일정을 수정하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      // rethrow;
      return false;
    }
  }

  Future<bool> deleteSchedule(int userId, int scheduleId) async {
    final Map<String, dynamic> body = {
      "user_id": userId,
      "schedule_id": scheduleId,
    };

    try {
      final response = await _apiClient.post(
        '/schedule/deleteSchedule',
        body: body,
      );
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Delete Schedule Successed") {
        deleteScheduleFromList(scheduleId);

        return true;
      } else {
        print('일정을 삭제하는 과정에서 에러 발생: $message');
        return false;
        // throw Exception('Delete Schedule Failed: $message');
      }
    } catch (e) {
      print('일정을 삭제하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      // rethrow;
      return false;
    }
  }

  // 일정을 DB 상에서 변경하고
  Future<bool> getFatigue(int userId, int scheduleId) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'schedule_id': scheduleId,
    };

    try {
      final response = await _apiClient.post(
        '/schedule/estimateScheduleFatigue',
        body: body,
      );

      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Estimate Schedule Fatigue Successed") {
        return true;
      } else {
        print('일정의 피로도를 계산하는 과정에서 에러 발생: $message');
        // throw Exception('Modify Schedule Failed: $message');
        return false;
      }
    } catch (e) {
      print('일정의 피로도를 계산하는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      // rethrow;
      return false;
    }
  }

  void findRecentScheduleIndex() {
    // 1. 시스템의 현재 날짜와 시간을 가져옵니다.
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    // 2. 현재 시간(분 단위)을 비교하기 쉬운 정수로 변환합니다. (예: 14:30 -> 870)
    final currentTimeInMinutes = currentTime.hour * 60 + currentTime.minute;

    // 3. .indexWhere를 사용하여 조건에 맞는 첫 번째 요소의 인덱스를 찾습니다.
    RecentScheudleIndex = _schedules.indexWhere((schedule) {
      // 조건 1: 스케줄의 날짜가 오늘 날짜와 같은지 확인
      final isToday =
          schedule.date.year == now.year &&
          schedule.date.month == now.month &&
          schedule.date.day == now.day;

      // 스케줄의 종료 시간을 비교하기 쉬운 정수로 변환
      final scheduleEndTimeInMinutes =
          schedule.endTime.hour * 60 + schedule.endTime.minute;

      // 조건 2: 스케줄의 종료 시간이 현재 시간 이후인지 확인
      final isAfterNow = scheduleEndTimeInMinutes > currentTimeInMinutes;

      // 두 조건이 모두 참인 첫 번째 일정을 찾습니다.
      return isToday && isAfterNow;
    });
  }

  bool checkConflict(Schedule newSchedule) {
    for (int i = RecentScheudleIndex; i < _schedules.length; i++) {
      Schedule schedule = schedules.elementAt(i);
      // 기존의 일정이 입력, 변경하는 일정보다 이후에 위치하게 되면 반복문을 종료 (이후는 검사를 할 필요가 없으니)
      if (schedule.date.isAfter(newSchedule.date)) {
        break;
      } else {
        // 두 일정의 날짜가 같은 경우
        if (schedule.date == newSchedule.date) {
          // 시간대가 중복되는 경우
          if (schedule.startTime.isBefore(newSchedule.endTime) &&
              schedule.endTime.isAfter(newSchedule.startTime)) {
            // 두 일정이 같은 일정이 아닌 경우 중복
            if (schedule.scheduleId != newSchedule.scheduleId) {
              return true;
            } else {
              continue;
            }
          } else {
            continue;
          }
        }
      }
    }

    return false;
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
      (s) => s.scheduleId == originalSchedule.scheduleId,
    );
    if (index != -1) {
      _schedules[index] = modifySchedule;
    }
    notifyListeners();

    print('[Client log] : 챗봇을 통해 스케줄 수정');
  }

  void deleteScheduleFromList(int scheduleId) {
    _schedules.removeWhere((s) => s.scheduleId == scheduleId);
  }

  int? findScheduleId(Schedule targetSchedule) {
    final index = _schedules.indexWhere((schedule) {
      // 비교를 위해 시간들을 정수로 변환
      final targetStartMinutes =
          targetSchedule.startTime.hour * 60 + targetSchedule.startTime.minute;
      final scheduleStartMinutes =
          schedule.startTime.hour * 60 + schedule.startTime.minute;
      final targetEndMinutes =
          targetSchedule.endTime.hour * 60 + targetSchedule.endTime.minute;
      final scheduleEndMinutes =
          schedule.endTime.hour * 60 + schedule.endTime.minute;

      // 모든 조건이 일치하는지 확인
      return schedule.title == schedule.title &&
          schedule.date.year == schedule.date.year &&
          schedule.date.month == schedule.date.month &&
          schedule.date.day == schedule.date.day &&
          scheduleStartMinutes == targetStartMinutes &&
          scheduleEndMinutes == targetEndMinutes;
    });

    // 인덱스를 찾았다면( -1이 아니라면), 해당 위치에 있는 schedule의 ID를 반환
    if (index != -1) {
      return _schedules[index].scheduleId!;
    } else {
      // 일치하는 일정이 없으면 null을 반환
      return null;
    }
  }

  // 날짜를 기준으로 빠른 순서대로 _schedules 리스트를 정렬하는 함수
  void sortSchedulesByDate() {
    // List의 sort 메서드 사용
    _schedules.sort((a, b) {
      // a.date와 b.date를 비교하여 정렬 순서를 결정
      return a.date.compareTo(b.date);
    });

    // 정렬된 결과가 UI에 반영되도록 리스너들에게 알림
    notifyListeners();
  }

  /// 특정 날짜(targetDate)와 정확히 일치하는 모든 Schedule 객체를 리스트로 반환합니다.
  List<Schedule> findSchedulesAtDate(DateTime targetDate) {
    return _schedules.where((schedule) {
      // schedule.date와 targetDate의 년, 월, 일이 모두 같은지 확인합니다.
      return schedule.date.year == targetDate.year &&
          schedule.date.month == targetDate.month &&
          schedule.date.day == targetDate.day;
    }).toList(); // where의 결과(Iterable)를 최종적으로 List로 변환합니다.
  }

  /// 특정 날짜(targetDate)와 시간대가 겹치는 모든 Schedule 객체를 리스트로 반환합니다.
  List<Schedule> findSchedulesAtDateAndTime(
    DateTime targetDate,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    // 1. 먼저 해당 날짜의 모든 일정을 찾습니다.
    final schedulesOnDate = findSchedulesAtDate(targetDate);

    // 2. 그 결과 중에서 시간이 겹치는 일정만 필터링합니다.
    return schedulesOnDate.where((schedule) {
      // A.startTime < B.endTime AND A.endTime > B.startTime
      // isBefore, isAfter는 TimeOfDay에서는 직접 사용할 수 없으므로,
      // 비교를 위해 분(minute) 단위로 변환합니다.
      final scheduleStartMinutes =
          schedule.startTime.hour * 60 + schedule.startTime.minute;
      final scheduleEndMinutes =
          schedule.endTime.hour * 60 + schedule.endTime.minute;
      final targetStartMinutes = startTime.hour * 60 + startTime.minute;
      final targetEndMinutes = endTime.hour * 60 + endTime.minute;

      // 중복 조건을 만족하면 true를 반환하여 리스트에 포함시킵니다.
      return scheduleStartMinutes < targetEndMinutes &&
          scheduleEndMinutes > targetStartMinutes;
    }).toList();
  }

  /// 특정 날짜(targetDate)를 포함하여 그 이후의 모든 Schedule 객체를 리스트로 반환합니다.
  List<Schedule> findSchedulesAfterDate(DateTime targetDate) {
    // 비교 기준이 되는 날짜의 자정(00:00:00)을 만듭니다.
    final startOfTargetDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    return _schedules.where((schedule) {
      // schedule.date가 startOfTargetDay보다 이전(before)이 아닌 경우,
      // 즉, 같거나 이후인 경우에만 true를 반환합니다.
      return !schedule.date.isBefore(startOfTargetDay);
    }).toList(); // where의 결과(Iterable)를 최종적으로 List로 변환합니다.
  }

  // ** 전달받은 Appointment 객체를 사용해서 원본 Schedule 객체를 찾아내는 헬퍼 함수. **
  Schedule? findScheduleByAppointment(dynamic appointment) {
    try {
      // schedules 리스트에서 appointment의 속성과 일치하는 첫 번째 Schedule을 찾음
      return _schedules.firstWhere(
        (schedule) =>
            schedule.title == appointment.subject &&
            schedule.startTime.hour == appointment.startTime.hour &&
            schedule.startTime.minute == appointment.startTime.minute &&
            schedule.endTime.hour == appointment.endTime.hour &&
            schedule.endTime.minute == appointment.endTime.minute &&
            schedule.location == appointment.location,
      );
    } catch (e) {
      // 일치하는 항목이 없으면 firstWhere는 에러를 던지므로, null을 반환
      return null;
    }
  }
}
