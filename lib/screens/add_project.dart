import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ✅ 1. 국제화 파일 import
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/project_service.dart';

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

  // ✅ 프로젝트 저장 로직
  Future<void> _saveProject() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. 유효성 검사 (빈 값 체크)
    if (_titleController.text.trim().isEmpty ||
        _goalController.text.trim().isEmpty ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        // l10n에 'fillRequiredFields'("필수 항목을 모두 입력해주세요") 키가 있다고 가정
        SnackBar(content: Text(l10n.fillRequiredFields)),
      );
      return;
    }

    // 2. Service 및 User Info 가져오기
    final authService = context.read<AuthService>();
    final projectService = context.read<ProjectService>();
    final userId = authService.currentUser?.userId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("로그인 정보가 없습니다.")));
      return;
    }

    // 3. 선택된 프로젝트 타입 확인 (ToggleButtons)
    // (참고: 현재 ProjectService.addProject에는 type 인자가 없어서 로직만 짜둡니다)
    String projectType = '기타';
    if (isSelected[0])
      projectType = '운동';
    else if (isSelected[1])
      projectType = '공부';

    try {
      // 4. 서버 통신 요청
      await projectService.addProject(
        userId,
        _titleController.text.trim(),
        _goalController.text.trim(),
        _selectedStartDate!,
        _selectedEndDate!,
        // ⚠️ 주의: ProjectService의 addProject 메서드를 수정하여
        // projectType도 함께 저장하도록 업데이트하는 것을 권장합니다.
      );

      // 5. 성공 시 화면 닫기
      if (mounted) {
        Navigator.pop(context, true); // true를 반환하며 닫음 (목록 갱신용)
      }
    } catch (e) {
      // 6. 실패 시 에러 메시지
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("프로젝트 생성 실패: $e")));
      }
    }
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
            onPressed: _saveProject,
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
