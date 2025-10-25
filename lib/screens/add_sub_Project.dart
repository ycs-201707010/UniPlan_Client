import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ✅ 1. 국제화 파일 import
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddSubProject extends StatefulWidget {
  const AddSubProject({super.key});

  @override
  State<AddSubProject> createState() => _AddSubProjectState();
}

class _AddSubProjectState extends State<AddSubProject> {
  final List<bool> _selectedDays = List.generate(7, (_) => true);
  String _selectedDaysText = "";
  bool? _isMultiPerDay = false; // 진척도 상승 제한

  @override
  void initState() {
    super.initState();
    // initState에서 l10n을 바로 사용할 수 없으므로, 초기 텍스트는 build에서 설정
  }

  // 선택된 요일에 따라 표시될 텍스트를 업데이트하는 함수
  void _updateSelectedDaysText(AppLocalizations l10n) {
    final List<String> daysList = [
      l10n.dowSunShort,
      l10n.dowMonShort,
      l10n.dowTueShort,
      l10n.dowWedShort,
      l10n.dowThuShort,
      l10n.dowFriShort,
      l10n.dowSatShort,
    ];

    final List<String> selectedDayNames = [];
    int count = 0;
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        selectedDayNames.add(daysList[i]);
        count++;
      }
    }

    if (count == 7) {
      _selectedDaysText = l10n.repeatEveryDay;
    } else if (count == 0) {
      _selectedDaysText = l10n.pleaseSelectDays;
    } else {
      _selectedDaysText = "${selectedDayNames.join(', ')}${l10n.repeatSuffix}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // build가 처음 호출될 때 초기 텍스트 설정
    if (_selectedDaysText.isEmpty) {
      _updateSelectedDaysText(l10n);
    }

    final List<Widget> days = [
      Text(l10n.dowSunShort),
      Text(l10n.dowMonShort),
      Text(l10n.dowTueShort),
      Text(l10n.dowWedShort),
      Text(l10n.dowThuShort),
      Text(l10n.dowFriShort),
      Text(l10n.dowSatShort),
    ];

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: TopBar(title: l10n.subGoalTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectProject),
              const SizedBox(height: 7),
              DropdownButtonFormField<Object>(
                isExpanded: true,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.task),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                hint: Text(l10n.selectProjectHint),
                items: [
                  // TODO: ProjectService에서 프로젝트 목록을 가져와 DropdownMenuItem으로 변환
                ],
                onChanged: (Object? newValue) {},
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  _selectedDaysText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ToggleButtons(
                  selectedBorderColor: Theme.of(context).colorScheme.primary,
                  selectedColor: Theme.of(context).colorScheme.onPrimary,
                  fillColor: Theme.of(context).colorScheme.primary,
                  color: Theme.of(context).colorScheme.primary,
                  isSelected: _selectedDays,
                  onPressed: (int index) {
                    setState(() {
                      _selectedDays[index] = !_selectedDays[index];
                      _updateSelectedDaysText(l10n);
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 48.0,
                  ),
                  children: days,
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.goalTitle),
              TextField(
                decoration: InputDecoration(hintText: l10n.goalTitleHint),
              ),
              const SizedBox(height: 24),
              Text(l10n.goalAmount),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(hintText: l10n.goalAmountHint),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.progressLimit,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  RadioListTile<bool>(
                    title: Text(l10n.progressOnceADay),
                    value: false,
                    groupValue: _isMultiPerDay,
                    onChanged: (bool? value) {
                      setState(() {
                        _isMultiPerDay = value;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text(l10n.progressMultipleTimesADay),
                    value: true,
                    groupValue: _isMultiPerDay,
                    onChanged: (bool? value) {
                      setState(() {
                        _isMultiPerDay = value;
                      });
                    },
                  ),
                ],
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
            onPressed: () {},
            child: Text(
              l10n.completeGoalSetting,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
