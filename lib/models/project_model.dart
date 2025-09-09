import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/models/subProject_model.dart';

@immutable
class Project {
  final int projectId;
  final String title;
  final String goal;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? timestamp;
  final List<SubProject>? subProjects;

  const Project({
    required this.projectId,
    required this.title,
    required this.goal,
    required this.startDate,
    required this.endDate,
    this.timestamp,
    this.subProjects,
  });

  Project copyWith({
    int? projectId,
    String? title,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? timestamp,
    List<SubProject>? subProjects,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      timestamp: timestamp ?? this.timestamp,
      subProjects: subProjects ?? this.subProjects,
    );
  }

  Map<String, dynamic> toJson() {
    // Pydantic의 date 타입에 맞추기 위해 'yyyy-MM-dd' 형식으로 변환 (시간 정보 제거)
    final String formattedStartDate = DateFormat(
      'yyyy-MM-dd',
    ).format(startDate);

    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    // // Pydantic의 time 타입에 맞추기 위해 'HH:mm:ss' 또는 'HH:mm' 형식으로 변환
    // // Fast API Pydantic은 보통 "HH:MM:SS" 또는 "HH:MM"을 잘 파싱합니다.
    // final String formattedStartTime =
    //     '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
    // final String formattedEndTime =
    //     '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

    // 최종 JSON Map 구성
    final Map<String, dynamic> jsonMap = {
      'project_id': projectId,
      'title': title,
      'goal': goal,
      'start_time': formattedStartDate,
      'end_time': formattedEndDate,
      if (timestamp != null) 'timestamp': timestamp,
    };

    /*
    if (subProject != null){
      for (i in subProject.size){sub.json}{
        jsonMap['sub_project'][i to String] = subProject.at(i).toJson:
      }
    }
    */

    return jsonMap;
  }

  //   // JSON 데이터를 받아 Project 객체를 생성하는 factory 생성자
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['project_id'] as int,
      title: json['title'] as String,
      goal: json['goal'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),

      timestamp:
          json['timestamp'] == null
              ? null
              : DateTime.parse(json['timestamp'] as String),

      /*
      subProject: if (DateTime.parse(json['timestamp'] as String) != null){
        for(int i = 0; i < (DateTime.parse(json['timestamp'] as String).size; i++){
          subProject.fromJson(DateTime.parse(json['timestamp'] as String[i])
        }
      },
      */
    );
  }
}
