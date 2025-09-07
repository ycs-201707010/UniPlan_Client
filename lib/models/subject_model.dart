import 'package:all_new_uniplan/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';

Map<String, int> weekdaySIMap = {
  '월': DateTime.monday,
  '화': DateTime.tuesday,
  '수': DateTime.wednesday,
  '목': DateTime.thursday,
  '금': DateTime.friday,
  '토': DateTime.saturday,
  '일': DateTime.sunday,
};

Map<int, String> weekdayISMap = {
  DateTime.monday: '월',
  DateTime.tuesday: '화',
  DateTime.wednesday: '수',
  DateTime.thursday: '목',
  DateTime.friday: '금',
  DateTime.saturday: '토',
  DateTime.sunday: '일',
};

// 시간표 정보를 저장하는 클래스
@immutable
class Subject {
  final subjectId;
  final String title;
  final int day;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? classroom;
  final String? professor;

  const Subject({
    this.subjectId,
    required this.title,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.classroom,
    this.professor,
  });

  Subject copyWith({
    int? subjectId,
    String? title,
    int? day,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? memo,
  }) {
    return Subject(
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      classroom: location ?? classroom,
      professor: memo ?? professor,
    );
  }

  Map<String, dynamic> toJson() {
    // Pydantic의 date 타입에 맞추기 위해 'yyyy-MM-dd' 형식으로 변환 (시간 정보 제거)

    // Pydantic의 time 타입에 맞추기 위해 'HH:mm:ss' 또는 'HH:mm' 형식으로 변환
    // Fast API Pydantic은 보통 "HH:MM:SS" 또는 "HH:MM"을 잘 파싱합니다.
    final String formattedStartTime =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
    final String formattedEndTime =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

    // 최종 JSON Map 구성
    final Map<String, dynamic> jsonMap = {
      'subject_id': subjectId,
      'title': title,
      'date': weekdayISMap[day],
      'start_time': formattedStartTime,
      'end_time': formattedEndTime,
      if (classroom != null) 'classroom': classroom,
      if (professor != null) 'professor': professor,
    };

    return jsonMap;
  }

  // JSON 데이터를 받아 Schedule 객체를 생성하는 factory 생성자
  factory Subject.fromJson(Map<String, dynamic> json) {
    // "HH:mm:ss" 형식의 문자열을 TimeOfDay 객체로 변환하는 헬퍼 함수
    TimeOfDay parseTimeOfDay(String timeString) {
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Subject(
      title: json['title'] as String,
      day: weekdaySIMap[json['day'] as String]!,
      startTime: parseTimeOfDay(json['start_time'] as String),
      endTime: parseTimeOfDay(json['end_time'] as String),

      // json에 해당 키가 없으면 null로 처리
      classroom: json['classroom'] as String?,
      professor: json['professor'] as String?,
    );
  }

  String getTimeToString() {
    String weekDay = "${weekdayISMap[day]!}요일";
    String period = "${startTime.hour - 8}교시-${endTime.hour - 8}교시";

    final formattedStartTime = formatTime(startTime);
    final formattedEndTime = formatTime(endTime);

    period = "$period($formattedStartTime - $formattedEndTime)";

    String timeString = "$weekDay $period";
    return timeString;
  }
}
