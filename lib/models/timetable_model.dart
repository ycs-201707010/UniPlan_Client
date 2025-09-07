import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/models/subject_model.dart';

@immutable
class Timetable {
  // 사용자가 선택한 기간
  DateTime? startDate;
  DateTime? endDate;
  int? tableId;

  String? location;

  // 1. 각 수업 정보를 담은 클래스를 저장하는 필드
  final List<Subject> _subjects = [];
  List<Subject>? get subjects => _subjects;

  // 2. 시간표를 startDate ~ endDate 까지 매 주의 일정을 생성해서 저장하는 필드
  // 기간에 맞춰 생성된 전체 반복 일정 목록
  final List<Schedule> _generatedSchedules = [];
  List<Schedule>? get generatedSchedules => _generatedSchedules;

  // 시간표의 반복 일정을 생성하는 과정에서 충돌/비충돌 일정을 각각 저장하는 필드
  final List<ScheduleConflict> _conflictingSchedules = [];
  List<ScheduleConflict>? get conflictingSchedules => _conflictingSchedules;

  final List<Schedule> _nonConflictingSchedules = [];
  List<Schedule>? get nonConflictingSchedules => _nonConflictingSchedules;

  // 각 요일별 일정을 저장하는 필드
  final Map<int, List<Subject>> _dayWithSchedule = {};
  Map<int, List<Subject>>? get dayWithSchedule => _dayWithSchedule;

  Timetable({this.startDate, this.endDate, this.tableId});

  void addSubjectToList(Subject subject) {
    _subjects.add(subject);
    addSubjectToDayMap(subject);
  }

  void addSubjectToDayMap(Subject subject) {
    final weekday = subject.day;

    // 해당 요일의 리스트가 맵에 아직 없다면, 새로 만듦
    if (_dayWithSchedule[weekday] == null) {
      _dayWithSchedule[weekday] = [];
    }

    _dayWithSchedule[weekday]!.add(subject);
  }

  void setPeriod(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) {
      return;
    }

    this.startDate = startDate;
    this.endDate = endDate;
  }

  void checkConflict(Schedule schedule) {}

  // void generateSchedules() {
  //   if (startDate!.isAfter(endDate!)) {
  //     return;
  //   }

  //   for (final subject in _subjects!) {
  //     // 시작일(startDate) 이후 요일이 같은 첫 번째 해당 날짜 찾기
  //     DateTime firstOccurrence = startDate!;
  //     while (firstOccurrence.weekday != subject.day) {
  //       firstOccurrence = firstOccurrence.add(const Duration(days: 1));
  //     }

  //     // 찾은 날짜부터 7일씩 건너뛰며 종료일(endDate)까지 일정 생성하여 리스트에 저장
  //     for (
  //       DateTime date = firstOccurrence;
  //       date.isBefore(endDate!.add(const Duration(days: 1)));
  //       date = date.add(const Duration(days: 7))
  //     ) {
  //       var schedule = Schedule(
  //         scheduleId: -1,
  //         title: subject.title,
  //         date: date,
  //         startTime: subject.startTime,
  //         endTime: subject.endTime,

  //         // json에 해당 키가 없으면 null로 처리
  //         // location: 추후에 사용자가 지정한 학교 위치로?,
  //         memo: [subject.professor, subject.classroom]
  //             .where(
  //               (s) => s != null && s.isNotEmpty,
  //             ) // null이 아니고 비어있지 않은 항목만 필터링
  //             .join(' - '), // 필터링된 항목들을 ' - '로 연결
  //       );

  //       _generatedSchedules!.add(schedule);
  //     }
  //   }
  // }

  int getRepeatCount(int targetWeekday) {
    if (startDate!.isAfter(endDate!)) {
      return 0;
    }

    int count = 0;
    DateTime currentDate = startDate!;

    // 1. 시작일(startDate) 이후 첫 번째 해당 요일 찾기
    while (currentDate.weekday != targetWeekday) {
      currentDate = currentDate.add(const Duration(days: 1));

      // 첫 요일을 찾다가 기간을 벗어나면 0을 반환
      if (currentDate.isAfter(endDate!)) {
        return 0;
      }
    }

    // 2. 찾은 첫 날짜부터 7일씩 건너뛰며 횟수 계산
    while (currentDate.isBefore(endDate!.add(const Duration(days: 1)))) {
      count++;
      currentDate = currentDate.add(const Duration(days: 7));
    }

    return count;
  }

  // 지정한 날짜 이후에 위치한 특정 요일을 찾는 메서드
  DateTime findNextWeekday(DateTime startDate, int targetWeekday) {
    // 현재 날짜를 startDate로 초기화
    DateTime currentDate = startDate;

    // 현재 날짜의 요일이 목표 요일과 같아질 때까지
    // 하루씩 날짜를 증가시킵니다.
    while (currentDate.weekday != targetWeekday) {
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return currentDate;
  }
  // Map<String, dynamic> toJson() {
  //   // Pydantic의 date 타입에 맞추기 위해 'yyyy-MM-dd' 형식으로 변환 (시간 정보 제거)
  //   final String formattedDate = DateFormat('yyyy-MM-dd').format(date!);

  //   // 최종 JSON Map 구성
  //   final Map<String, dynamic> jsonMap = {
  //     'schedule_id': subProjectId,
  //     'subgoal': subGoal,
  //     if (done != null) 'done': done,
  //     if (maxDone != null) 'max_done': maxDone,
  //     if (cycle != null) 'cycle': cycle,
  //     if (date != null) 'date': formattedDate,
  //     if (projectType != null) 'project_type': projectType,
  //   };

  //   return jsonMap;
  // }

  // Map<String, dynamic> toMultiJson() {
  //   // Pydantic의 date 타입에 맞추기 위해 'yyyy-MM-dd' 형식으로 변환 (시간 정보 제거)
  //   final String formattedDate = DateFormat('yyyy-MM-dd').format(date!);

  //   // 최종 JSON Map 구성
  //   final Map<String, dynamic> jsonMap = {
  //     'schedule_id': subProjectId,
  //     'subgoal': subGoal,
  //     if (done != null) 'done': done,
  //     if (maxDone != null) 'max_done': maxDone,
  //     if (cycle != null) 'cycle': cycle,
  //     if (date != null) 'date': formattedDate,
  //     if (projectType != null) 'project_type': projectType,
  //   };

  //   return jsonMap;
  // }
  // JSON 데이터를 받아 SubProject 객체를 생성하는 factory 생성자
  // factory SubProject.fromJson(Map<String, dynamic> json) {
  //   return SubProject(
  //     subProjectId: json['subproject_id'] as int,
  //     subGoal: json['subgoal'] as String,
  //     done: json['done'] as int?,
  //     maxDone: json['max_done'] as int?,
  //     cycle: json['cycle'] as int?,
  //     date:
  //         json['date'] == null ? null : DateTime.parse(json['date'] as String),
  //     projectType: json['project_type'] as String?,
  //   );
  // }
}

// 충돌이 발생한 일정의 쌍을 저장하는 클래스
class ScheduleConflict {
  final Schedule timeTableSchedule; // 새로 추가하려는 시간표 일정
  final Schedule existingSchedule; // 겹치는 기존 일정

  ScheduleConflict({
    required this.timeTableSchedule,
    required this.existingSchedule,
  });
}
