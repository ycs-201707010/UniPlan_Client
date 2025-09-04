// ** this is dummy data !! **

import 'package:flutter/material.dart';

class Schedule {
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final String memo;

  Schedule({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.memo,
  });
}
