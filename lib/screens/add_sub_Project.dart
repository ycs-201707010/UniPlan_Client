import 'package:all_new_uniplan/models/project_model.dart';
import 'package:all_new_uniplan/services/project_service.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // ✅ Provider import
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddSubProject extends StatefulWidget {
  const AddSubProject({super.key});

  @override
  State<AddSubProject> createState() => _AddSubProjectState();
}

class _AddSubProjectState extends State<AddSubProject> {
  // ✅ 1. 입력값 제어를 위한 컨트롤러 및 변수 추가
  final TextEditingController _subGoalController = TextEditingController();
  final TextEditingController _maxDoneController = TextEditingController();

  int? _selectedProjectId; // 선택된 프로젝트 ID 저장

  final List<bool> _selectedDays = List.generate(7, (_) => true);
  String _selectedDaysText = "";
  bool _isMultiPerDay = false; // null 대신 false를 기본값으로 사용

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subGoalController.dispose();
    _maxDoneController.dispose();
    super.dispose();
  }

  // 선택된 요일에 따라 표시될 텍스트 업데이트
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

  // ✅ 3. 하위 프로젝트 저장 로직 (수정됨: 요일별 개별 저장)
  Future<void> _saveSubProject() async {
    final l10n = AppLocalizations.of(context)!;
    final projectService = context.read<ProjectService>();

    // --- 1. 유효성 검사 ---
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectProjectHint)));
      return;
    }
    if (_subGoalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.goalTitleHint)));
      return;
    }
    if (_maxDoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.goalAmountHint)));
      return;
    }

    // 요일이 하나도 선택되지 않았을 경우
    if (!_selectedDays.contains(true)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectDays)));
      return;
    }

    // --- 2. 저장 로직 시작 ---
    try {
      // DB ENUM 값에 맞춘 소문자 요일 리스트
      final List<String> dbDays = [
        'sun',
        'mon',
        'tue',
        'wed',
        'thu',
        'fri',
        'sat',
      ];

      // 병렬 처리를 위해 Future 리스트 생성
      List<Future> apiCalls = [];

      for (int i = 0; i < 7; i++) {
        // 해당 요일이 선택되었다면
        if (_selectedDays[i]) {
          // 개별 요일에 대한 저장 요청을 리스트에 담습니다.
          apiCalls.add(
            projectService.addSubProject(
              _selectedProjectId!,
              _subGoalController.text.trim(),
              int.parse(_maxDoneController.text.trim()),
              _isMultiPerDay,
              weekDay: dbDays[i], // ✅ "mon", "tue" 처럼 하나씩 보냄
              // color: ...
            ),
          );
        }
      }

      // ✅ 3. 모든 요일의 저장이 끝날 때까지 기다림 (병렬 처리로 속도 향상)
      await Future.wait(apiCalls);

      if (mounted) {
        Navigator.pop(context, true); // 성공 시 뒤로가기
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("하위 목표가 추가되었습니다.")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("추가 실패: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // ✅ 4. ProjectService에서 프로젝트 목록 가져오기
    final projectService = context.watch<ProjectService>();
    // values를 리스트로 변환 (null일 경우 빈 리스트)
    final List<Project> projects =
        projectService.projects?.values.toList() ?? [];

    if (_selectedDaysText.isEmpty) {
      _updateSelectedDaysText(l10n);
    }

    final List<Widget> daysWidgets = [
      Text(l10n.dowSunShort),
      Text(l10n.dowMonShort),
      Text(l10n.dowTueShort),
      Text(l10n.dowWedShort),
      Text(l10n.dowThuShort),
      Text(l10n.dowFriShort),
      Text(l10n.dowSatShort),
    ];

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

              // ✅ 5. 드롭다운 버튼 구현
              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _selectedProjectId,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.task),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(), // 테두리 추가 (선택사항)
                ),
                hint: Text(l10n.selectProjectHint),
                items:
                    projects.map((project) {
                      return DropdownMenuItem<int>(
                        value: project.projectId,
                        child: Text(
                          project.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedProjectId = newValue;
                  });
                },
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
                    minWidth: 40.0, // 화면 폭에 따라 좁을 수 있어 너비 조정
                  ),
                  children: daysWidgets,
                ),
              ),

              const SizedBox(height: 24),

              Text(l10n.goalTitle),
              TextField(
                controller: _subGoalController, // ✅ 컨트롤러 연결
                decoration: InputDecoration(hintText: l10n.goalTitleHint),
              ),

              const SizedBox(height: 24),

              Text(l10n.goalAmount),
              TextField(
                controller: _maxDoneController, // ✅ 컨트롤러 연결
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
                        _isMultiPerDay = value ?? false;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text(l10n.progressMultipleTimesADay),
                    value: true,
                    groupValue: _isMultiPerDay,
                    onChanged: (bool? value) {
                      setState(() {
                        _isMultiPerDay = value ?? true;
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
            // ✅ 6. 저장 함수 연결
            onPressed: _saveSubProject,
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
