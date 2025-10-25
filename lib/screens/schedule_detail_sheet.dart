// ** 등록된 일정 상세 정보 **

import 'package:all_new_uniplan/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleDetailSheet extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleDetailSheet({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 16),
            ),
          ),
          Text(
            appointment.subject,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (appointment.location != null && appointment.location!.isNotEmpty)
            Text("${context.l10n.detailLocation}: ${appointment.location}"),
          const SizedBox(height: 4),
          Text(
            "${context.l10n.detailStart}: ${DateFormat(context.l10n.fullDateTimeFormat, 'ko').format(appointment.startTime)}",
          ),
          Text(
            "${context.l10n.detailEnd}: ${DateFormat(context.l10n.fullDateTimeFormat, 'ko').format(appointment.endTime)}",
          ),
          const SizedBox(height: 4),
          if (appointment.notes != null && appointment.notes!.isNotEmpty)
            Text("${context.l10n.detailNotes}: ${appointment.notes}"),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 수정 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: Text(context.l10n.edit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              // 삭제 버튼
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  label: Text(context.l10n.delete),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
