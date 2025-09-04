import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';

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
          return Appointment(
            startTime: start,
            endTime: end,
            subject: s.title,
            location: s.location,
            notes: s.memo,
            color: Colors.deepPurple,
          );
        }).toList();
  }
}
