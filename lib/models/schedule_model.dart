import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@immutable
class Schedule {
  final int? scheduleId; // DB에서 일정을 식별하기 위해 사용?
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? location;
  final String? memo;
  final double? fatigue_level;
  final String? color;
  final bool? isLongProject;
  final int? projectId;
  final DateTime? timestamp;

  const Schedule({
    this.scheduleId,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.memo,
    this.color,
    this.fatigue_level,
    this.isLongProject,
    this.projectId,
    this.timestamp,
  });

  @override
  String toString() {
    return '''
    --- Schedule Object ---
      scheduleId: $scheduleId
      title: '$title'
      date: $date
      startTime: $startTime
      endTime: $endTime
      location: $location
      memo: $memo
      color: $color
      isLongProject: $isLongProject
      projectId: $projectId
    -----------------------
    ''';
  }

  Schedule copyWith({
    int? scheduleId,
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? memo,
    double? fatigue_level,
    String? color,
    bool? isLongProject,
    int? projectId,
    DateTime? timestamp,
  }) {
    return Schedule(
      // ?? : 왼쪽의 값이 null이면, 오른쪽의 값을 사용하라.
      scheduleId: scheduleId ?? this.scheduleId,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      memo: memo ?? this.memo,
      fatigue_level: fatigue_level ?? this.fatigue_level,
      color: color ?? this.color,
      isLongProject: isLongProject ?? this.isLongProject,
      projectId: projectId ?? this.projectId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    // Pydantic의 date 타입에 맞추기 위해 'yyyy-MM-dd' 형식으로 변환 (시간 정보 제거)
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Pydantic의 time 타입에 맞추기 위해 'HH:mm:ss' 또는 'HH:mm' 형식으로 변환
    // Fast API Pydantic은 보통 "HH:MM:SS" 또는 "HH:MM"을 잘 파싱합니다.
    final String formattedStartTime =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
    final String formattedEndTime =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

    // 최종 JSON Map 구성
    final Map<String, dynamic> jsonMap = {
      if (scheduleId != null) 'schedule_id': scheduleId,
      'title': title,
      'date': formattedDate,
      'start_time': formattedStartTime,
      'end_time': formattedEndTime,
      if (location != null) 'location': location,
      if (memo != null) 'memo': memo,
      if (fatigue_level != null) 'fatigue_level': fatigue_level,
      if (color != null) 'color': color,
      if (isLongProject != null) 'isLongProject': isLongProject,
      if (projectId != null) 'project_id': projectId,
      if (timestamp != null) 'timestamp': timestamp,
    };

    return jsonMap;
  }

  // JSON 데이터를 받아 Schedule 객체를 생성하는 factory 생성자
  factory Schedule.fromJson(Map<String, dynamic> json) {
    // "HH:mm:ss" 형식의 문자열을 TimeOfDay 객체로 변환하는 헬퍼 함수
    TimeOfDay parseTimeOfDay(String timeString) {
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Schedule(
      scheduleId: json['schedule_id'] as int?,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: parseTimeOfDay(json['start_time'] as String),
      endTime: parseTimeOfDay(json['end_time'] as String),

      // json에 해당 키가 없으면 null로 처리
      location: json['location'] as String?,
      memo: json['memo'] as String?,
      fatigue_level: (json['fatigue_level'] as num?)?.toDouble(),
      color: json['color'] as String?,
      isLongProject: json['is_long_project'] as bool?,
      projectId: json['project_id'] as int?,
      timestamp:
          json['timestamp'] == null
              ? null
              : DateTime.parse(json['timestamp'] as String),
    );
  }
}
