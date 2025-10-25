import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/models/subject_model.dart';

@immutable
class Timetable {
  int? tableId;
  String? title;
  DateTime? startDate;
  DateTime? endDate;
  String? location;

  // 1. 각 수업 정보를 담은 클래스를 저장하는 필드
  List<Subject>? subjects = [];
  List<Subject>? get getSubjects => subjects;

  // 2. 시간표를 startDate ~ endDate 까지 매 주의 일정을 생성해서 저장하는 필드
  // 기간에 맞춰 생성된 전체 반복 일정 목록
  List<Schedule>? _generatedSchedules = [];
  List<Schedule>? get generatedSchedules => _generatedSchedules;

  // 각 요일별 일정을 저장하는 필드
  Map<int, List<Subject>>? _dayWithSchedule = {};
  Map<int, List<Subject>>? get dayWithSchedule => _dayWithSchedule;

  Timetable({
    this.title,
    this.startDate,
    this.endDate,
    this.tableId,
    this.subjects,
  });

  Timetable copyWith({List<Subject>? subjects}) {
    return Timetable(
      tableId: this.tableId,
      title: this.title,
      subjects: subjects ?? this.subjects,
    );
  }

  void addSubjectToList(Subject subject) {
    // 👇 subjects가 null이면 빈 리스트를 할당
    subjects ??= [];
    // 이제 subjects는 null이 아님W이 보장됨
    subjects!.add(subject);
    addSubjectToDayMap(subject);
  }

  void addSubjectToDayMap(Subject subject) {
    final weekday = subject.day;

    // 해당 요일의 리스트가 맵에 아직 없다면, 새로 만듦
    if (_dayWithSchedule![weekday] == null) {
      _dayWithSchedule![weekday] = [];
    }

    _dayWithSchedule![weekday]!.add(subject);
  }

  void setPeriod(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) {
      return;
    }

    this.startDate = startDate;
    this.endDate = endDate;
  }

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
  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      title: json['title'] as String,
      tableId: json['class_id'] as int,
    );
  }
}
