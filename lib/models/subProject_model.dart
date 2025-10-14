import 'package:flutter/material.dart'; // color를 위해 import
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/models/subProject_progress_model.dart';

Map<String, String> weekdaySEMap = {
  '월': "mon",
  '화': "tue",
  '수': "wed",
  '목': "thu",
  '금': "fri",
  '토': "sat",
  '일': "sun",
};

Map<String, String> weekdayESMap = {
  "mon": '월',
  "tue": '화',
  "wed": '수',
  "thu": '목',
  "fri": '금',
  "sat": '토',
  "sun": '일',
};

@immutable
// ignore: must_be_immutable
class SubProject {
  final int? subProjectId;
  final String? subGoal;
  int? done;
  final int? maxDone;
  final String? weekDay;
  bool? multiPerDay = false;
  final String? color;
  List<SubProjectProgress>? progresses;

  SubProject({
    this.subProjectId,
    this.subGoal,
    this.done,
    this.maxDone,
    this.weekDay,
    this.multiPerDay,
    this.color,
    this.progresses,
  });

  SubProject copyWith({
    int? subProjectId,
    String? subGoal,
    int? done,
    int? maxDone,
    String? weekDay,
    bool? multiPerDay,
    String? color,
    List<SubProjectProgress>? progresses,
  }) {
    return SubProject(
      subProjectId: subProjectId ?? this.subProjectId,
      subGoal: subGoal ?? this.subGoal,
      done: done ?? this.done,
      maxDone: maxDone ?? this.maxDone,
      weekDay: weekDay ?? this.weekDay,
      multiPerDay: multiPerDay ?? this.multiPerDay,
      color: color ?? this.color,
      progresses: progresses ?? this.progresses,
    );
  }

  Map<String, dynamic> toJson() {
    // 최종 JSON Map 구성
    final Map<String, dynamic> jsonMap = {
      // 값이 null이 아닐 경우에만 JSON에 포함
      if (subProjectId != null) 'subproject_id': subProjectId,
      if (subGoal != null) 'subgoal': subGoal,
      if (done != null) 'done': maxDone,
      if (maxDone != null) 'max_done': maxDone,
      if (weekDay != null) 'week_day': weekDay,
      if (multiPerDay != null) 'multi_per_day': multiPerDay,
      if (color != null) 'color': color,
    };
    return jsonMap;
  }

  factory SubProject.fromJson(Map<String, dynamic> json) {
    return SubProject(
      subProjectId: json['subproject_id'] as int?,
      subGoal: json['subgoal'] as String?,
      done: json['done'] as int?,
      maxDone: json['max_done'] as int?,
      weekDay: json['weekday'] as String?,
      multiPerDay: json['multi_per_day'] as bool?,
      color: json['color'] as String?,
    );
  }

  // List<SubProject> fromLLMJson(List<dynamic> subProjectListJson) {
  //   List<SubProject> subProjectList = [];

  //   for (var subProjectJson in subProjectListJson) {
  //     subProjectJson = subProjectJson as Map<String, dynamic>;

  //     List<String> weekDays = subProjectJson['weekdays'] as List<String>;

  //     for (final weekDay in weekDays) {
  //       SubProject(
  //         subProjectId: subProjectJson['subproject_id'] as int?,
  //         subGoal: subProjectJson['subgoal'] as String?,
  //         done: subProjectJson['done'] as int?,
  //         maxDone: subProjectJson['max_done'] as int?,
  //         weekDay: weekDay,
  //         multiPerDay: false,
  //         color: subProjectJson['color'] as String?,
  //       );
  //     }
  //   }

  //   return subProjectList;
  // }

  void addProgressToList(SubProjectProgress progress) {
    progresses!.add(progress);
  }
}
