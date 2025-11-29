import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷용

class BirthdayPicker extends StatefulWidget {
  final void Function(DateTime) onDateChanged; // ✅ 추가

  const BirthdayPicker({super.key, required this.onDateChanged});

  @override
  State<BirthdayPicker> createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends State<BirthdayPicker> {
  DateTime _selectedDate = DateTime(2000, 1, 1); // 기본값;

  DateTime get selectedDate => _selectedDate;

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 350,
          child: CupertinoDatePicker(
            initialDateTime: _selectedDate,
            mode: CupertinoDatePickerMode.date,
            maximumDate: DateTime.now(),
            minimumYear: 1900,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _selectedDate = newDate;
              });

              widget.onDateChanged(newDate); // 부모 위젯(signup.dart에 위치함)에게 전달
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayText = DateFormat(
      'yyyy년 MM월 dd일',
    ).format(_selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(displayText, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}
