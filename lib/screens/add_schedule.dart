// ** 일정을 직접 등록하는 화면 **
import 'package:all_new_uniplan/models/place_model.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/screens/location_deside_page.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/place_service.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:all_new_uniplan/widgets/basicDialog.dart';
import 'package:all_new_uniplan/widgets/common_text_field.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// ✅ 1. 자동 생성된 국제화 파일을 import 합니다.
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:all_new_uniplan/l10n/l10n.dart';

class AddSchedulePage extends StatefulWidget {
  final BuildContext rootContext;
  final Schedule? initialSchedule; // ← null 가능

  const AddSchedulePage({
    super.key,
    required this.rootContext,
    this.initialSchedule,
  });

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  Schedule? originalSchedule;

  late String barTitle;
  late String buttonTitle;

  // 이미 등록된 일정 수정 시, 날짜를 포맷
  String _formatTime(TimeOfDay time, AppLocalizations l10n) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat(l10n.timeFormat, 'ko').format(dt);
  }

  @override
  void initState() {
    super.initState();
    // initState에서는 context를 직접 사용할 수 없으므로, didChangeDependencies에서 처리
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ AppLocalizations 인스턴스를 가져옵니다.
    final l10n = AppLocalizations.of(context)!;

    if (widget.initialSchedule != null) {
      barTitle = l10n.editScheduleTitle;
      buttonTitle = l10n.editScheduleTitle;

      final schedule = widget.initialSchedule!;

      selectedDate = schedule.date;
      startTime = schedule.startTime;
      endTime = schedule.endTime;
      dateController.text = DateFormat(
        l10n.dateFormat,
        'ko',
      ).format(schedule.date);
      startTimeController.text = _formatTime(schedule.startTime, l10n);
      endTimeController.text = _formatTime(schedule.endTime, l10n);
      titleController.text = schedule.title;
      locationController.text = schedule.location ?? '';
      memoController.text = schedule.memo ?? '';

      originalSchedule = widget.initialSchedule!;
    } else {
      barTitle = l10n.addSchedule;
      buttonTitle = l10n.addSchedule;
    }
  }

  // 시간 비교를 위한 보조 함수.
  int _timeOfDayToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  /// 날짜 선택
  DateTime? selectedDate;

  final TextEditingController titleController = TextEditingController(); // 일정명
  final TextEditingController dateController = TextEditingController();

  Future<void> pickDate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: today,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ko'),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat(l10n.dateFormat, 'ko').format(picked);
      });
    }
  }

  /// 시간 선택
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  TimeOfDay getInitialTime() {
    final now = DateTime.now();
    if (selectedDate == null) return TimeOfDay.now();
    final isToday =
        selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;
    return isToday ? TimeOfDay.now() : const TimeOfDay(hour: 0, minute: 0);
  }

  Future<void> pickTime(BuildContext context, bool isStart) async {
    final l10n = AppLocalizations.of(context)!;
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectDateFirst),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: getInitialTime(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final isToday =
          selectedDate!.year == now.year &&
          selectedDate!.month == now.month &&
          selectedDate!.day == now.day;

      if (isToday &&
          (picked.hour < now.hour ||
              (picked.hour == now.hour && picked.minute < now.minute))) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotSelectPastTime),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );
        return;
      }

      setState(() {
        final now = DateTime.now();
        final dt = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
        final formattedTime = DateFormat(l10n.timeFormat, 'ko').format(dt);

        if (isStart) {
          startTime = picked;
          startTimeController.text = formattedTime;
        } else {
          endTime = picked;
          endTimeController.text = formattedTime;
        }
      });
    }
  }

  /// 위치 선택
  final TextEditingController locationController = TextEditingController();

  Future<void> pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LocationDesidePage()),
    );
    if (result != null) {
      setState(() {
        locationController.text = result['address'];
      });
    }
  }

  /// 메모 작성
  final TextEditingController memoController = TextEditingController();

  void addSchedule() async {
    final l10n = AppLocalizations.of(context)!;
    final authService = context.read<AuthService>();
    final scheduleService = context.read<ScheduleService>();

    final userId = authService.currentUser!.userId;
    final title = titleController.text.trim();
    final date = selectedDate;
    final start = startTime;
    final end = endTime;
    String? location;
    String? memo;
    String color = colorToHex(_selectedColor);

    if (locationController.text.isNotEmpty) {
      location = locationController.text;
    }
    if (memoController.text.isNotEmpty) {
      memo = memoController.text.trim();
    }

    if (title.isEmpty || date == null || start == null || end == null) {
      showAlert(context, l10n.fillRequiredFields);
      return;
    }
    if (_timeOfDayToMinutes(start) >= _timeOfDayToMinutes(end)) {
      showAlert(context, l10n.startTimeBeforeEndTime);
      return;
    }

    final bool isSuccess = await scheduleService.addSchedule(
      userId,
      title,
      date,
      start,
      end,
      location: location,
      memo: memo,
      isLongProject: false,
      color: color,
    );

    if (!context.mounted) return;
    Navigator.of(context).pop(isSuccess);
  }

  Color _pickerColor = const Color(0xFF00FFA3);
  Color _selectedColor = const Color(0xFF00FFA3);

  void changeColor(color) {
    setState(() {
      _pickerColor = color;
    });
  }

  Future pickColor(type) {
    final l10n = AppLocalizations.of(context)!;
    Widget pickerType;
    if (type == 'ColorPicker') {
      pickerType = ColorPicker(
        pickerColor: _pickerColor,
        onColorChanged: changeColor,
      );
    } else if (type == 'MaterialPicker') {
      pickerType = MaterialPicker(
        pickerColor: _pickerColor,
        onColorChanged: changeColor,
      );
    } else {
      pickerType = BlockPicker(
        pickerColor: _pickerColor,
        onColorChanged: changeColor,
      );
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectColorTitle),
          content: SingleChildScrollView(child: pickerType),
          actions: <Widget>[
            ElevatedButton(
              child: Text(l10n.selectColorButton),
              onPressed: () {
                setState(() => _selectedColor = _pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String colorToHex(Color color) {
    String argb = color.toARGB32().toRadixString(16).padLeft(8, "0");
    return '#${argb.substring(2, 8)}';
  }

  void modifySchedule() async {
    final l10n = AppLocalizations.of(context)!;
    final authService = context.read<AuthService>();
    final scheduleService = context.read<ScheduleService>();

    final userId = authService.currentUser!.userId;
    final title = titleController.text.trim();
    final date = selectedDate;
    final start = startTime;
    final end = endTime;
    String? location;
    String? memo;
    String color = colorToHex(_selectedColor);

    if (locationController.text.isNotEmpty) {
      location = locationController.text;
    }
    if (memoController.text.isNotEmpty) {
      memo = memoController.text.trim();
    }

    if (title.isEmpty || date == null || start == null || end == null) {
      showAlert(context, l10n.fillRequiredFields);
      return;
    }
    if (_timeOfDayToMinutes(start) >= _timeOfDayToMinutes(end)) {
      showAlert(context, l10n.startTimeBeforeEndTime);
      return;
    }

    Schedule newSchedule = Schedule(
      title: title,
      date: date,
      startTime: startTime!,
      endTime: endTime!,
      location: location,
      memo: memo,
      isLongProject: false,
      color: color,
    );

    final bool isSuccess = await scheduleService.modifySchedule(
      userId,
      originalSchedule!,
      newSchedule,
    );

    if (!context.mounted) return;
    Navigator.of(context).pop(isSuccess);
  }

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    locationController.dispose();
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeService = context.watch<PlaceService>();
    final places = placeService.placeList;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: TopBar(title: barTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              CommonTextField(
                controller: titleController,
                label: l10n.scheduleTitleLabel,
                hintText: l10n.scheduleTitleHint,
              ),

              const SizedBox(height: 16),

              // 날짜
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: l10n.dateLabel,
                  hintText: l10n.dateHint,
                  suffixIcon: Icon(Icons.calendar_today),
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                readOnly: true,
                onTap: () {
                  pickDate(context);
                },
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.startTimeLabel,
                      ),
                      onTap: () => pickTime(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endTimeController,
                      readOnly: true,
                      decoration: InputDecoration(labelText: l10n.endTimeLabel),
                      onTap: () => pickTime(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.locationLabel),
              TextField(
                controller: locationController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: l10n.selectLocationHint,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: PopupMenuButton<Object>(
                    icon: const Icon(Icons.arrow_drop_down),
                    tooltip: "저장된 장소 목록",
                    onSelected: (Object? newValue) {
                      if (newValue is Place) {
                        setState(() {
                          locationController.text = newValue.name;
                        });
                      } else if (newValue == 'direct_select') {
                        pickLocation();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<Object>(
                          value: 'direct_select',
                          child: Text(l10n.selectLocationDirectly),
                        ),
                        const PopupMenuDivider(),
                        ...places.map<PopupMenuEntry<Object>>((Place place) {
                          return PopupMenuItem<Object>(
                            value: place,
                            child: Text(place.name),
                          );
                        }),
                      ];
                    },
                  ),
                ),
                onTap: pickLocation,
              ),
              const SizedBox(height: 16),
              Text(l10n.notesLabel),
              TextField(maxLines: 5, controller: memoController),
              const SizedBox(height: 24),
              Text(l10n.colorLabel),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => pickColor('ColorPicker'),
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: bottomInset > 0 ? bottomInset + 20 : 20,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () async {
              if (originalSchedule != null) {
                modifySchedule();
              } else {
                addSchedule();
              }
            },
            child: Text(
              buttonTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
