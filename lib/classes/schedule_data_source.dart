import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';

Color hexToColor(String hexString) {
  final buffer = StringBuffer();

  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');

  buffer.write(hexString.replaceFirst('#', ''));

  return Color(int.parse(buffer.toString(), radix: 16));
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> schedules) {
    appointments =
        schedules.map((s) {
          final start = DateTime(
            s.date.year,
            s.date.month,
            s.date.day,
            s.startTime.hour,
            s.startTime.minute,
          );
          final end = DateTime(
            s.date.year,
            s.date.month,
            s.date.day,
            s.endTime.hour,
            s.endTime.minute,
          );

          // ✅ 1. s.color가 null이거나 비어 있는지 확인
          final bool hasColor = s.color != null && s.color!.isNotEmpty;

          return Appointment(
            startTime: start,
            endTime: end,
            subject: s.title,
            location: s.location,
            notes: s.memo,
            color: hasColor ? hexToColor(s.color!) : Colors.deepPurple,
          );
        }).toList();
  }
}
