import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddProject extends StatefulWidget {
  const AddProject({super.key});

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  // ** 프로젝트 종류 : 세 가지 그룹 중 하나만 선택한다. **
  List<bool> isSelected = [false, false, false];
  List<Color> typeColor = [Colors.orange, Colors.blueAccent, Color(0xFF1bb373)];
  final List<Widget> buttons = const [Text('운동'), Text('학업'), Text('미선택')];

  @override
  Widget build(BuildContext context) {
    String barTitle = '프로젝트 추가';
    String buttonTitle = '프로젝트 추가하기';

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // 날짜 선택
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();

    // 2. 날짜 선택을 위한 공통 함수
    Future<void> pickDate(
      BuildContext context, {
      required bool isStartDate,
    }) async {
      // 종료일을 먼저 선택하려는 경우 예외 처리
      if (!isStartDate && selectedStartDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('시작 기간을 먼저 선택해주세요.')));
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final pickedDate = await showDatePicker(
        context: context,
        initialDate:
            (isStartDate ? selectedStartDate : selectedEndDate) ?? today,
        // 시작일 선택 시: 오늘부터 선택 가능
        // 종료일 선택 시: 시작일(selectedStartDate)부터 선택 가능
        firstDate: isStartDate ? today : selectedStartDate!,
        lastDate: DateTime(now.year + 5),
        locale: const Locale('ko'),
      );

      if (pickedDate == null) return; // 사용자가 취소한 경우

      setState(() {
        if (isStartDate) {
          selectedStartDate = pickedDate;
          startDateController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(pickedDate);
          // 시작일 변경 시, 기존 종료일이 시작일보다 앞서게 되면 종료일을 초기화
          if (selectedEndDate != null && pickedDate.isAfter(selectedEndDate!)) {
            selectedEndDate = null;
            endDateController.clear();
          }
        } else {
          selectedEndDate = pickedDate;
          endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      });
    }

    @override
    void dispose() {
      startDateController.dispose();
      endDateController.dispose();
      super.dispose();
    }

    return Scaffold(
      appBar: TopBar(title: barTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text("프로젝트 종류"),
              SizedBox(height: 7),
              LayoutBuilder(
                builder: (context, constraints) {
                  // ✅ 2. 각 버튼이 차지할 너비를 계산합니다.
                  //    (전체 너비 / 버튼 개수)
                  final buttonWidth =
                      (constraints.maxWidth - 10) / buttons.length;

                  return ToggleButtons(
                    color: Theme.of(context).colorScheme.onSurface,
                    selectedColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    selectedBorderColor: Theme.of(context).colorScheme.primary,
                    splashColor: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4.0),
                    constraints: BoxConstraints(minHeight: 36.0),
                    isSelected: isSelected,

                    onPressed: (index) {
                      setState(() {
                        for (int i = 0; i < isSelected.length; i++) {
                          isSelected[i] = (i == index);
                        }
                      });
                    },
                    // ✅ 3. 각 자식 위젯을 고정된 너비의 SizedBox로 감쌉니다.
                    children:
                        buttons.map((widget) {
                          return SizedBox(
                            width: buttonWidth, // 계산된 너비 적용
                            child: Center(child: widget), // 텍스트를 중앙에 배치
                          );
                        }).toList(),
                    // ... (borderRadius 등 다른 스타일 속성)
                  );
                },
              ),
              SizedBox(height: 16),

              const Text("프로젝트 제목"),
              TextField(),

              SizedBox(height: 16),

              const Text("수행 기간"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startDateController,
                      readOnly: true,
                      decoration: InputDecoration(labelText: '시작 기간'),
                      onTap: () => pickDate(context, isStartDate: true),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endDateController,
                      readOnly: true,
                      decoration: InputDecoration(labelText: '종료 기간'),
                      onTap: () => pickDate(context, isStartDate: false),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              const Text("목표"),
              TextField(),
            ],
          ),
        ),
      ),

      // ✅ 하단 버튼 (키보드에 따라 위로 밀려 올라감)
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: bottomInset > 0 ? bottomInset + 20 : 20, // 키보드가 올라올 때 +10 여유
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            // ** 눌렀을 때 이벤트 **
            onPressed: () {},

            child: Text(
              buttonTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
