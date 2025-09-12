import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@immutable
class SubProject {
  final int? subProjectId;
  final String subGoal;
  final int? done;
  final int? maxDone;
  final int? cycle;
  final DateTime? date;
  final String? projectType;

  const SubProject({
    this.subProjectId,
    required this.subGoal,
    this.done,
    this.maxDone,
    this.cycle,
    this.date,
    this.projectType,
  });

  SubProject copyWith({
    int? subProjectId,
    String? subGoal,
    int? done,
    int? maxDone,
    int? cycle,
    DateTime? date,
    String? projectType,
  }) {
    return SubProject(
      subProjectId: subProjectId ?? this.subProjectId,
      subGoal: subGoal ?? this.subGoal,
      done: done ?? this.done,
      maxDone: maxDone ?? this.maxDone,
      cycle: cycle ?? this.cycle,
      date: date ?? this.date,
      projectType: projectType ?? this.projectType,
    );
  }

  Map<String, dynamic> toJson() {
    // Pydantic의 date 타입에 맞추기 위해 'yyyy-MM-dd' 형식으로 변환 (시간 정보 제거)
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date!);

    // 최종 JSON Map 구성
    final Map<String, dynamic> jsonMap = {
      if (subProjectId != null) 'subproject_id': subProjectId,
      'subgoal': subGoal,
      if (done != null) 'done': done,
      if (maxDone != null) 'max_done': maxDone,
      if (cycle != null) 'cycle': cycle,
      if (date != null) 'date': formattedDate,
      if (projectType != null) 'project_type': projectType,
    };

    return jsonMap;
  }

  // JSON 데이터를 받아 SubProject 객체를 생성하는 factory 생성자
  factory SubProject.fromJson(Map<String, dynamic> json) {
    return SubProject(
      subProjectId: json['subproject_id'] as int,
      subGoal: json['subgoal'] as String,
      done: json['done'] as int?,
      maxDone: json['max_done'] as int?,
      cycle: json['cycle'] as int?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      projectType: json['project_type'] as String?,
    );
  }
}
