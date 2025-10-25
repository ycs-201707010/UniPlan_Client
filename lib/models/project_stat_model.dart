import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/models/subProject_model.dart';

class Stat {
  final int projectId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalTask;
  final int completeTask;
  final double percent;

  Stat({
    required this.projectId,
    required this.startDate,
    required this.endDate,
    required this.totalTask,
    required this.completeTask,
    required this.percent,
  });

  Stat copyWith({
    int? projectId,
    DateTime? startDate,
    DateTime? endDate,
    int? totalTask,
    int? completeTask,
    double? percent,
  }) {
    return Stat(
      projectId: projectId ?? this.projectId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalTask: totalTask ?? this.totalTask,
      completeTask: completeTask ?? this.completeTask,
      percent: percent ?? this.percent,
    );
  }

  // JSON 데이터를 받아 Project 객체를 생성하는 factory 생성자
  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      projectId: json['project_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalTask: json['total_task'] as int,
      completeTask: json['complete_task'] as int,
      percent: json['percent'] as double,
    );
  }
}
