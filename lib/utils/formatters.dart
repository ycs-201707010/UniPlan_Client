import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

  return formattedDate;
}

String formatTime(TimeOfDay time) {
  final String formattedTime =
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  return formattedTime;
}
