// ** 에브리타임과 연결하여 시간표를 불러오는 페이지 **

import 'package:all_new_uniplan/screens/conflict_resolution_page.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/everytime_service.dart';
import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ✅ 1. 재사용 가능한 커스텀 위젯 (리스트의 각 항목)
class SubjectListItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const SubjectListItem({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class EverytimeLinkPage extends StatefulWidget {
  final BuildContext rootContext;
  const EverytimeLinkPage({super.key, required this.rootContext});

  @override
  State<EverytimeLinkPage> createState() => _EverytimeLinkPageState();
}

class _EverytimeLinkPageState extends State<EverytimeLinkPage> {
  // URL로부터 과목을 전부 로드했는지 판별하는 상태 변수
  bool loadTimeTable = false;

  final TextEditingController URLController = TextEditingController();

  // ✅ 3. 데이터 리스트 (실제로는 서버 등에서 받아옴)
  List<Map<String, String>> subjects = [];

  final TextEditingController titleController =
      TextEditingController(); // 시간표 제목

  /// 날짜 선택
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  Future<void> pickDate(
    BuildContext context,
    bool isStarted,
    TextEditingController dateController,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // 과거 제거용

    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStarted ? selectedStartDate ?? now : selectedEndDate ?? now,
      firstDate: today, // 오늘 이전의 날짜는 선택 불가임.
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ko'),
    );
    if (picked != null) {
      print('시작 날짜 : $selectedStartDate');
      print('종료 날짜 : $selectedEndDate');
      setState(() {
        if (isStarted == true) {
          selectedStartDate = picked;
        } else {
          selectedEndDate = picked;
        }

        dateController.text = DateFormat('yyyy-MM-dd (E)', 'en').format(picked);
      });
    }
  }

  bool _isButtonEnabled = false;

  void _validateFields() {
    setState(() {
      _isButtonEnabled =
          titleController.text.isNotEmpty &&
          startDateController.text.isNotEmpty &&
          endDateController.text.isNotEmpty;
    });
  }

  // 로딩 상태를 관리할 변수 추가함
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ 3. 각 컨트롤러에 리스너를 추가하여 텍스트 변경을 감지
    titleController.addListener(_validateFields);
    startDateController.addListener(_validateFields);
    endDateController.addListener(_validateFields);
  }

  @override
  void dispose() {
    // ✅ 4. 위젯이 제거될 때 리스너도 함께 제거 (메모리 누수 방지)
    titleController.removeListener(_validateFields);
    startDateController.removeListener(_validateFields);
    endDateController.removeListener(_validateFields);
    titleController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    URLController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final everytimeService = context.watch<EverytimeService>();
    final authService = context.watch<AuthService>();

    return Stack(
      children: [
        Scaffold(
          appBar: TopBar(title: "시간표 불러오기"),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    '등록된 과목을 다수 불러와\n시간표에 저장할 수 있습니다.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(height: 36),

                Container(
                  child: Text(
                    '1. 에브리타임 시간표 URL을 입력란에 붙여넣기\n하신 뒤, "시간표 불러오기" 버튼을 눌러주세요',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: URLController,
                  decoration: InputDecoration(hintText: "여기에 URL 붙여넣기"),
                ),

                SizedBox(height: 12),

                InkWell(
                  onTap: () async {
                    // TODO : URL을 통해 시간표에서 과목을 불러오고 리스트에 저장하도록
                    if (URLController.text.isEmpty == true) {
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    subjects = [];

                    final everytimeUrl = URLController.text;

                    await everytimeService.getEverytimeSchedule(everytimeUrl);

                    final crolledSubjects =
                        everytimeService.currentTimetable!.subjects!;

                    for (int i = 0; i < crolledSubjects.length; i++) {
                      setState(() {
                        subjects.add({
                          'title': crolledSubjects[i].title,
                          'subtitle': crolledSubjects[i].getTimeToString(),
                        });
                      });

                      if (i == crolledSubjects.length - 1) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  splashColor: Colors.transparent, // 터치 시 음영 제거
                  highlightColor: Colors.transparent, // 길게 눌렀을 때 음영 제거
                  child: Container(
                    width: double.infinity, // 부모 위젯의 너비에 맞춤
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xEEF91F15), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo_everytime.png',
                          width: 48,
                          height: 48,
                        ),

                        Text(
                          "에브리타임 시간표 불러오기",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 36),

                Container(
                  child: Text(
                    '2. 불러온 시간표의 과목 목록을 확인해주세요',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 스프레드 연산자를 사용.
                      for (int i = 0; i < subjects.length; i++) ...[
                        SubjectListItem(
                          title: subjects[i]['title']!,
                          subtitle: subjects[i]['subtitle']!,
                        ),

                        // 마지막 항목이 아닐 때만 Divider를 추가
                        if (i < subjects.length - 1)
                          Divider(
                            height: 1, // Divider의 높이 (상하 여백 포함)
                            thickness: 1, // 선의 두께
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 36),

                Container(
                  child: Text(
                    '3. 전부 올바르게 불러와졌다면, 시간표의 제목과\n기간 범위를 설정해주세요',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(height: 16),
                const Text("일정 제목"),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startDateController,
                        readOnly: true,
                        decoration: InputDecoration(labelText: '시작 일자'),
                        onTap:
                            () => pickDate(context, true, startDateController),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: endDateController,
                        readOnly: true,
                        decoration: InputDecoration(labelText: '종료 일자'),
                        onTap:
                            () => pickDate(context, false, endDateController),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 150),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        _isButtonEnabled
                            ? () async {
                              // TODO : 실제 시간표를 등록하는 로직을 구현하라
                              final userId = authService.currentUser!.userId;
                              final title = titleController.text;
                              final startDate = selectedStartDate;
                              final endDate = selectedEndDate;

                              await everytimeService.addTimetable(
                                authService.currentUser!.userId,
                                title,
                              );

                              final result = await showYesNoAlertDialog(
                                context,
                              );

                              if (result == true) {
                                await everytimeService.addTimetableSchedule(
                                  userId,
                                  title,
                                  startDate!,
                                  endDate!,
                                );
                                print(
                                  everytimeService.conflictingSchedules!.length,
                                );
                                if (everytimeService
                                        .conflictingSchedules!
                                        .length !=
                                    0) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (pageContext) =>
                                              ConflictResolutionPage(),
                                    ),
                                  );
                                }
                              }

                              everytimeService.callNotifyListeners();

                              if (!context.mounted) return;

                              Navigator.of(context).pop(true);
                            }
                            : null,

                    child: const Text(
                      '시간표 등록하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // _isLoading이 true일 때만 로딩 화면을 보여줌
        if (_isLoading)
          Container(
            color: const Color(0x80000000), // 반투명 검은 배경 (암전)
            child: Center(
              // TODO : 챗봇에서 사용했던 로딩 연출로 변경
              child: SpinKitFadingCube(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Future<bool?> showYesNoAlertDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 사용자가 다이얼로그 바깥을 터치해도 닫히지 않게 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('시간표 일정 추가'), // 다이얼로그 제목
          content: Text('시간표 데이터를 지정한 기간 동안 \n캘린더에 일정으로 추가하시겠습니까?'), // 다이얼로그 내용
          actions: <Widget>[
            // "아니오" 버튼
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.pop(context, false); // false를 반환하며 다이얼로그 닫기
              },
            ),
            // "예" 버튼
            TextButton(
              child: Text('예'),
              onPressed: () {
                Navigator.pop(context, true); // true를 반환하며 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
