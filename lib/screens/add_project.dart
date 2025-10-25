import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ✅ 1. 국제화 파일 import
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddProject extends StatefulWidget {
  const AddProject({super.key});

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  // ✅ 2. 상태 변수와 컨트롤러를 State 클래스의 멤버로 이동
  List<bool> isSelected = [true, false, false]; // 기본 선택

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // 날짜 선택을 위한 공통 함수
  Future<void> _pickDate({required bool isStartDate}) async {
    final l10n = AppLocalizations.of(context)!;
    if (!isStartDate && _selectedStartDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectStartDateFirst)));
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          (isStartDate ? _selectedStartDate : _selectedEndDate) ?? today,
      firstDate: isStartDate ? today : _selectedStartDate!,
      lastDate: DateTime(now.year + 5),
      locale: Locale(l10n.localeName),
    );

    if (pickedDate == null) return;

    setState(() {
      if (isStartDate) {
        _selectedStartDate = pickedDate;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        if (_selectedEndDate != null && pickedDate.isAfter(_selectedEndDate!)) {
          _selectedEndDate = null;
          _endDateController.clear();
        }
      } else {
        _selectedEndDate = pickedDate;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ✅ 3. 버튼 텍스트 리스트도 build 메서드 안으로 이동
    final List<Widget> buttons = [
      Text(l10n.projectTypeExercise),
      Text(l10n.projectTypeStudy),
      Text(l10n.projectTypeNone),
    ];

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: TopBar(title: l10n.projectAdd),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.projectType),
              const SizedBox(height: 10),
              Center(
                child: ToggleButtons(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: Theme.of(context).colorScheme.primary,
                  selectedColor: Theme.of(context).colorScheme.onPrimary,
                  fillColor: Theme.of(context).colorScheme.primary,
                  color: Theme.of(context).colorScheme.primary,
                  constraints: const BoxConstraints(
                    minWidth: 110.0,
                    minHeight: 36.0,
                  ),
                  isSelected: isSelected,
                  onPressed: (index) {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == index);
                      }
                    });
                  },

                  children:
                      buttons.map((widget) {
                        return SizedBox(child: Center(child: widget));
                      }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              Text(l10n.projectTitle),
              TextField(controller: _titleController),
              const SizedBox(height: 16),
              Text(l10n.projectDuration),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.projectStartDate,
                      ),
                      onTap: () => _pickDate(isStartDate: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _endDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.projectEndDate,
                      ),
                      onTap: () => _pickDate(isStartDate: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.projectGoal),
              TextField(controller: _goalController),
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
            onPressed: () {},
            child: Text(
              l10n.projectAddButton,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
