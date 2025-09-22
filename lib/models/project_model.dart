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
  final String? project_type;
  final List<SubProject>? subProjects;

  const Project({
    required this.projectId,
    required this.title,
    required this.goal,
    required this.startDate,
    required this.endDate,
    this.timestamp,
    this.project_type,
    this.subProjects,
  });

  Project copyWith({
    int? projectId,
    String? title,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? timestamp,
    String? project_type,
    List<SubProject>? subProjects,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      timestamp: timestamp ?? this.timestamp,
      project_type: project_type ?? this.project_type,
      subProjects: subProjects ?? this.subProjects,
    );
  }

  Map<String, dynamic> toJson() {
    // Pydantic의 date 타입에 맞추기 위해 'yyyy-MM-dd' 형식으로 변환 (시간 정보 제거)
    final String formattedStartDate = DateFormat(
      'yyyy-MM-dd',
    ).format(startDate);

    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    // 최종 JSON Map 구성
    final Map<String, dynamic> jsonMap = {
      'project_id': projectId,
      'title': title,
      'goal': goal,
      'start_date': formattedStartDate,
      'end_date': formattedEndDate,
      if (timestamp != null) 'timestamp': timestamp,
      if (project_type != null) 'project_type': project_type,
    };

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
      project_type:
          json['project_type'] == null ? null : json['project_type'] as String,
    );
  }
}
