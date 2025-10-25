// import 'package:all_new_uniplan/models/project_model.dart';
// import 'package:all_new_uniplan/models/subProject_model.dart';
// import 'package:all_new_uniplan/screens/project_chatbot.dart';
// import 'package:all_new_uniplan/services/auth_service.dart';
// import 'package:all_new_uniplan/services/project_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:toastification/toastification.dart';

// class ProjectPage extends StatefulWidget {
//   const ProjectPage({super.key});

//   @override
//   State<ProjectPage> createState() => _ProjectPageState();
// }

// class _ProjectPageState extends State<ProjectPage> {
//   // ** 상태 변수 **
//   bool _isLoading = true;
//   CalendarFormat _calendarFormat =
//       CalendarFormat.week; // 기본 뷰 : 주간. 토글 버튼으로 월간/주간 뷰 교체 가능
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   Map<int, List<SubProject>> _subProjectList = {};

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadInitialData();
//     });
//   }

//   // TODO : 프로젝트를 불러오는 함수
//   Future<void> _loadInitialData() async {
//     final projectService = context.read<ProjectService>();
//     final authService = context.read<AuthService>();

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // 사용자 ID로 모든 프로젝트와 하위 프로젝트 데이터를 불러옵니다.
//       await projectService.getProjectByUserId(authService.currentUser!.userId);
//     } catch (e) {
//       if (mounted) {
//         // todo : toastification로 변경
//         // ScaffoldMessenger.of(
//         //   context,
//         // ).showSnackBar(SnackBar(content: Text('프로젝트를 불러오는 데 실패했습니다: $e')));
//         toastification.show(
//           context: context,
//           type: ToastificationType.error,
//           style: ToastificationStyle.flatColored,
//           autoCloseDuration: const Duration(seconds: 3),
//           title: const Text('프로젝트를 불러오는 데 실패했습니다'),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _loadSubProjectByDate() async {
//     final projectService = context.read<ProjectService>();
//     if (projectService.projects == null) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final Map<int, List<SubProject>> newSubProjects = {};

//       for (final project in projectService.projects!.values) {
//         // 해당 날짜의 하위 프로젝트 목록을 서버에서 가져옴
//         final subProjects = await projectService.getSubProjectByDate(
//           project.projectId!,
//           _focusedDay,
//         );
//         if (subProjects.isNotEmpty) {
//           newSubProjects[project.projectId!] = subProjects;
//         }
//       }

//       // 모든 요청이 끝나면 상태를 한 번에 업데이트
//       setState(() {
//         _subProjectList = newSubProjects;
//       });
//       print("SubProjectList : $_subProjectList");
//     } catch (e) {
//       if (mounted) {
//         toastification.show(
//           context: context,
//           type: ToastificationType.error,
//           style: ToastificationStyle.flatColored,
//           autoCloseDuration: const Duration(seconds: 3),
//           title: const Text('프로젝트 Task를 불러오는 데 실패했습니다'),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // 뷰의 상태를 변경하는 함수.
//   void _onFormatChange(CalendarFormat format) {
//     if (_calendarFormat != format) {
//       setState(() {
//         _calendarFormat = format;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // watch를 사용하여 ProjectService의 데이터 변경을 감지
//     final projectService = context.watch<ProjectService>();
//     final projects = projectService.projects?.values.toList() ?? [];

//     return Stack(
//       children: [
//         Scaffold(
//           // todo : Schedule 화면에서 쓴 appBar를 컴포넌트화 시켜서 여기서도 사용
//           appBar: CustomAppBar(
//             currentFormat: _calendarFormat,
//             onFormatChanged: _onFormatChange,
//           ),
//           body: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TableCalendar(
//                   // 세로 스와이프를 막는 속성.
//                   availableGestures: AvailableGestures.horizontalSwipe,

//                   locale: 'en_US', //'ko_KR',
//                   firstDay: DateTime.utc(
//                     2025,
//                     03,
//                     01,
//                   ), // todo : 사용자의 계정 가입일로 변경??
//                   lastDay: DateTime.utc(2033, 12, 31),
//                   focusedDay: _focusedDay,

//                   headerStyle: HeaderStyle(
//                     titleCentered: true,
//                     formatButtonVisible: false,
//                   ),

//                   daysOfWeekHeight: 35, // 일~토요일 표시줄의 세로 너비
//                   // 주간/월간 뷰 토글 기능
//                   calendarFormat: _calendarFormat,
//                   onFormatChanged: (format) {
//                     setState(() {
//                       _calendarFormat = format;
//                     });
//                   },

//                   // 날짜 선택 기능
//                   selectedDayPredicate: (day) {
//                     return isSameDay(_selectedDay, day);
//                   },
//                   onDaySelected: (selectedDay, focusedDay) {
//                     setState(() {
//                       _selectedDay = selectedDay;
//                       _focusedDay = focusedDay; // 선택된 날짜로 포커스 이동

//                       print("_selectedDay : $_selectedDay");
//                       print("_focusedDay : $_focusedDay");

//                       _loadSubProjectByDate();
//                     });
//                   },

//                   calendarBuilders: CalendarBuilders(
//                     // ✅ 1. 일반 날짜(평일, 주말)를 위한 빌더
//                     defaultBuilder: (context, day, focusedDay) {
//                       // 일요일(7) 또는 토요일(6)인지 확인
//                       if (day.weekday == DateTime.sunday ||
//                           day.weekday == DateTime.saturday) {
//                         return Center(
//                           child: Text(
//                             '${day.day}',
//                             style: TextStyle(
//                               color:
//                                   day.weekday == DateTime.sunday
//                                       ? Colors.red
//                                       : Colors.blue,
//                             ),
//                           ),
//                         );
//                       }
//                       // 평일은 기본 스타일을 사용하도록 null 반환
//                       return null;
//                     },

//                     // ✅ 2. '오늘' 날짜가 주말일 경우를 위한 빌더
//                     todayBuilder: (context, day, focusedDay) {
//                       // '오늘'을 표시하는 원형 데코레이션은 calendarStyle에서 처리되므로,
//                       // 여기서는 텍스트 스타일만 지정합니다.
//                       return Center(
//                         child: Container(
//                           width: 40,
//                           height: 40,
//                           margin: EdgeInsets.all(4.0),
//                           alignment: Alignment.center,
//                           padding: EdgeInsets.all(7),
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color:
//                                   (day.weekday == DateTime.sunday)
//                                       ? Colors.red
//                                       : (day.weekday == DateTime.saturday)
//                                       ? Colors.blue
//                                       : Theme.of(context).colorScheme.primary,
//                               width: 2.0,
//                             ),
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child: Text(
//                             '${day.day}',
//                             style: TextStyle(
//                               // '오늘' 날짜가 주말이면 색상 적용, 아니면 기본 색상(흰색 등)
//                               color:
//                                   (day.weekday == DateTime.sunday)
//                                       ? Colors.red
//                                       : (day.weekday == DateTime.saturday)
//                                       ? Colors.blue
//                                       : Theme.of(context).colorScheme.onSurface,
//                             ),
//                           ),
//                         ),
//                       );
//                     },

//                     // ✅ 3. '선택된' 날짜가 주말일 경우를 위한 빌더
//                     selectedBuilder: (context, day, focusedDay) {
//                       // '선택'을 표시하는 원형 데코레이션은 calendarStyle에서 처리되므로,
//                       // 여기서는 텍스트 스타일만 지정합니다.
//                       return Center(
//                         child: Container(
//                           width: 40,
//                           height: 40,
//                           margin: EdgeInsets.all(4.0),
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             color:
//                                 (day.weekday == DateTime.sunday)
//                                     ? Colors.red
//                                     : (day.weekday == DateTime.saturday)
//                                     ? Colors.blue
//                                     : Theme.of(context).colorScheme.primary,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Text(
//                             '${day.day}',
//                             style: TextStyle(
//                               // '선택된' 날짜가 주말이면 색상 적용, 아니면 기본 색상(흰색 등)
//                               color: Theme.of(context).colorScheme.onPrimary,
//                               fontWeight: FontWeight.bold, // 선택된 날짜는 굵게
//                             ),
//                           ),
//                         ),
//                       );
//                     },

//                     dowBuilder: (context, day) {
//                       final text = DateFormat.E().format(day);

//                       if (day.weekday == DateTime.sunday) {
//                         return Center(
//                           child: Text(
//                             text,
//                             style: TextStyle(color: Colors.red),
//                           ),
//                         );
//                       } else if (day.weekday == DateTime.saturday) {
//                         return Center(
//                           child: Text(
//                             text,
//                             style: TextStyle(color: Colors.blue),
//                           ),
//                         );
//                       }
//                       return null;
//                     },
//                   ),
//                 ),

//                 SizedBox(height: 32),

//                 // Container(
//                 //   margin: EdgeInsets.only(left: 15),
//                 //   child: Text(
//                 //     '등록된 과목을 다수 불러와\n시간표에 저장할 수 있습니다.',
//                 //     style: TextStyle(
//                 //       color: Colors.black,
//                 //       fontWeight: FontWeight.w600,
//                 //       fontSize: 16,
//                 //     ),
//                 //   ),
//                 // ),
//                 for (final project in projects)
//                   if (_subProjectList.containsKey(project.projectId))
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         bottom: 32.0,
//                         left: 17,
//                         right: 17,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // --- 프로젝트(카테고리) 제목 ---
//                           Text(
//                             project.title,
//                             style: const TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange,
//                             ), // 색상은 동적으로 변경 가능
//                           ),
//                           Divider(color: Colors.orange.shade300, thickness: 2),
//                           const SizedBox(height: 8),

//                           //--- 하위 프로젝트(목표) 목록 ---
//                           if (_subProjectList[project.projectId!] != null)
//                             for (final subProject
//                                 in _subProjectList[project.projectId!]!)
//                               // 하위 프로젝트를 하나씩 카드로 표시
//                               ProjectProgressCard(
//                                 subProjectId: subProject.subProjectId!,
//                                 title: subProject.subGoal!,
//                                 currentStep: subProject.done ?? 0,
//                                 maxStep:
//                                     subProject.maxDone ??
//                                     1, // maxDone이 null이면 1로 처리
//                                 multiPerDay: subProject.multiPerDay!,

//                                 // ✅ 1. 진척도 증가 (탭)
//                                 onIncrement: () async {
//                                   // 현재 진척도가 최대치보다 작을 때만 실행
//                                   if ((subProject.done ?? 0) <
//                                       (subProject.maxDone ?? 1)) {
//                                     final result = await projectService
//                                         .addSubProjectProgress(
//                                           subProject.subProjectId!,
//                                           _focusedDay,
//                                         );

//                                     if (result) _loadSubProjectByDate();
//                                   }
//                                 },

//                                 // ✅ 2. 진척도 감소 (롱프레스)
//                                 onDecrement: () {
//                                   // 현재 진척도가 0보다 클 때만 실행
//                                   if ((subProject.done ?? 0) > 0) {
//                                     projectService.cancelSubProjectProgress(
//                                       subProject.subProjectId!,
//                                       _focusedDay, // -1 감소
//                                     );
//                                   }
//                                 },

//                                 // ✅ 3. 삭제 (슬라이드)
//                                 onDelete: () {
//                                   // 실수로 삭제하는 것을 방지하기 위해 확인 다이얼로그를 띄웁니다.
//                                   showDialog(
//                                     context: context,
//                                     builder: (BuildContext dialogContext) {
//                                       return AlertDialog(
//                                         title: const Text('목표 삭제'),
//                                         content: Text(
//                                           '\'${subProject.subGoal}\' 목표를 정말 삭제하시겠습니까?',
//                                         ),
//                                         actions: [
//                                           TextButton(
//                                             onPressed:
//                                                 () =>
//                                                     Navigator.of(
//                                                       dialogContext,
//                                                     ).pop(), // 취소
//                                             child: const Text('아니오'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               // ProjectService의 삭제 메서드 호출
//                                               context
//                                                   .read<ProjectService>()
//                                                   .deleteSubProject(
//                                                     project.projectId!,
//                                                     subProject.subProjectId!,
//                                                   );
//                                               Navigator.of(
//                                                 dialogContext,
//                                               ).pop(); // 다이얼로그 닫기
//                                             },
//                                             child: const Text(
//                                               '예',
//                                               style: TextStyle(
//                                                 color: Colors.red,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 },
//                               )
//                           else
//                             const Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('등록된 하위 목표가 없습니다.'),
//                             ),
//                         ],
//                       ),
//                     ),
//               ],
//             ),
//           ),

//           floatingActionButton: SpeedDial(
//             icon: Icons.add,
//             activeIcon: Icons.close,
//             backgroundColor: Theme.of(context).colorScheme.primary, // 버튼 배경색
//             foregroundColor:
//                 Theme.of(context).colorScheme.onPrimary, // 버튼 내부의 아이콘 색

//             children: [
//               SpeedDialChild(
//                 child: Icon(Icons.android),
//                 label: "프로젝트 챗봇",
//                 onTap: () async {
//                   await Navigator.push<bool>(
//                     context,
//                     MaterialPageRoute(
//                       builder: (pageContext) => ProjectChatbot(),
//                     ),
//                   );
//                 },
//               ),

//               SpeedDialChild(
//                 child: Icon(Icons.calendar_today),
//                 label: '세부 목표 짜기',
//                 onTap: () async {
//                   // 일정 추가 창으로 이동, 일정 추가 결과에 따른 결과를 반환받음.
//                   // final result = await Navigator.push<bool>(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //     builder:
//                   //         (pageContext) =>
//                   //             AddSchedulePage(rootContext: context),
//                   //   ),
//                   // );

//                   // // TODO : 일정이 성공적으로 추가되었다면, 일정 추가창에서 캘린더 창으로 bool 형식의 응답을 하고, 일정 추가에 성공한 응답을 받으면 일정이 추가되었다는 Dialog 알림 주기
//                   // if (result == true) {
//                   //   // 성공했을 때 Toast 알림
//                   //   if (!context.mounted) return; // context 유효성 검사

//                   //   toastification.show(
//                   //     context:
//                   //         context, // optional if you use ToastificationWrapper
//                   //     type: ToastificationType.success,
//                   //     style: ToastificationStyle.flatColored,
//                   //     autoCloseDuration: const Duration(seconds: 3),
//                   //     title: Text('제하하하하하!! 일정을 등록했다!!'),
//                   //   );
//                   // }
//                 },
//               ),

//               SpeedDialChild(
//                 child: Icon(Icons.calendar_today),
//                 label: '프로젝트 생성',
//                 onTap: () async {
//                   // 일정 추가 창으로 이동, 일정 추가 결과에 따른 결과를 반환받음.
//                   // final result = await Navigator.push<bool>(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //     builder:
//                   //         (pageContext) =>
//                   //             AddSchedulePage(rootContext: context),
//                   //   ),
//                   // );

//                   // // TODO : 일정이 성공적으로 추가되었다면, 일정 추가창에서 캘린더 창으로 bool 형식의 응답을 하고, 일정 추가에 성공한 응답을 받으면 일정이 추가되었다는 Dialog 알림 주기
//                   // if (result == true) {
//                   //   // 성공했을 때 Toast 알림
//                   //   if (!context.mounted) return; // context 유효성 검사

//                   //   toastification.show(
//                   //     context:
//                   //         context, // optional if you use ToastificationWrapper
//                   //     type: ToastificationType.success,
//                   //     style: ToastificationStyle.flatColored,
//                   //     autoCloseDuration: const Duration(seconds: 3),
//                   //     title: Text('제하하하하하!! 일정을 등록했다!!'),
//                   //   );
//                   // }
//                 },
//               ),
//             ],
//           ),
//         ),

//         // _isLoading이 true일 때만 로딩 화면을 보여줌
//         if (_isLoading)
//           Container(
//             color: const Color(0x80000000), // 반투명 검은 배경 (암전)
//             child: Center(
//               // TODO : 챗봇에서 사용했던 로딩 연출로 변경
//               child: SpinKitFadingCube(
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// // 상단의 AppBar
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   // ✅ 4. 부모로부터 받을 함수와 상태 변수를 선언합니다.
//   final CalendarFormat currentFormat;
//   final Function(CalendarFormat) onFormatChanged;

//   const CustomAppBar({
//     super.key,
//     required this.currentFormat,
//     required this.onFormatChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Image.asset('assets/images/logo.png', height: 45),
//           // 토글 버튼 컨테이너
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surfaceContainer,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // '월' 버튼
//                 _buildFormatButton(
//                   context,
//                   CalendarFormat.month,
//                   'Mon',
//                   currentFormat == CalendarFormat.month,
//                 ),
//                 // '주' 버튼
//                 _buildFormatButton(
//                   context,
//                   CalendarFormat.week,
//                   'Week',
//                   currentFormat == CalendarFormat.week,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ 5. 버튼을 만드는 로직을 별도 함수로 분리하여 가독성 향상
//   Widget _buildFormatButton(
//     BuildContext context,
//     CalendarFormat format,
//     String text,
//     bool isSelected,
//   ) {
//     return GestureDetector(
//       onTap: () => onFormatChanged(format), // ✅ 6. 전달받은 함수(콜백)를 호출
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color:
//               isSelected
//                   ? Theme.of(context).colorScheme.primary
//                   : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color:
//                 isSelected
//                     ? Theme.of(context).colorScheme.onPrimary
//                     : Theme.of(context).colorScheme.onSurfaceVariant,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

// // 하위 프로젝트를 표시할 카드 위젯.
// class ProjectProgressCard extends StatelessWidget {
//   final int subProjectId;
//   final String title;
//   final int currentStep;
//   final int maxStep;
//   final bool multiPerDay;

//   final VoidCallback onIncrement;
//   final VoidCallback onDecrement;
//   final VoidCallback onDelete;

//   const ProjectProgressCard({
//     super.key,
//     required this.subProjectId,
//     required this.maxStep,
//     required this.title,
//     required this.currentStep,
//     required this.multiPerDay,
//     required this.onIncrement,
//     required this.onDecrement,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // 진행률 계산 (0.0 ~ 1.0)
//     final double progress = (maxStep == 0) ? 0.0 : currentStep / maxStep;
//     final bool isCompleted = currentStep >= maxStep;

//     // ✅ 2. 전체를 Slidable 위젯으로 감쌉니다.
//     return Slidable(
//       key: ValueKey(title), // 각 항목을 구분하기 위한 Key
//       groupTag: 'sub-project-list', // 하나의 항목만 열리도록 그룹 지정
//       // 왼쪽으로 슬라이드했을 때 나타날 '삭제' 버튼
//       endActionPane: ActionPane(
//         motion: const DrawerMotion(),
//         extentRatio: 0.25, // 차지할 너비
//         children: [
//           SlidableAction(
//             onPressed: (context) => onDelete(), // ✅ onDelete 콜백 호출
//             backgroundColor: Colors.red,
//             foregroundColor: Colors.white,
//             icon: Icons.delete,
//             label: '삭제',
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ],
//       ),

//       // ✅ 3. 기존 UI를 InkWell로 감싸서 탭, 롱프레스 제스처를 추가합니다.
//       child: InkWell(
//         onTap: onIncrement, // ✅ 짧게 탭 -> onIncrement 콜백 호출
//         onLongPress: () {
//           HapticFeedback.mediumImpact(); // 길게 눌렀을 때 진동 피드백
//           onDecrement(); // ✅ 길게 누르기 -> onDecrement 콜백 호출
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           // ... (기존 Container 코드는 그대로)
//           margin: const EdgeInsets.symmetric(vertical: 8.0),
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             color: Theme.of(context).scaffoldBackgroundColor,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.orange.shade300, width: 1.5),
//           ),
//           child: Row(
//             children: [
//               // ✅ 2. 목표 제목과 진행도 바 (대부분의 공간 차지)
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     // ✅ 3. 진행도 바
//                     LinearProgressIndicator(
//                       value: progress,
//                       backgroundColor: Colors.grey[300],
//                       valueColor: const AlwaysStoppedAnimation<Color>(
//                         Colors.orange,
//                       ),
//                       minHeight: 6,
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),

//               // ✅ 4. 진행률 텍스트와 아이콘
//               Column(
//                 children: [
//                   Text(
//                     '$currentStep/$maxStep',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Icon(
//                     isCompleted ? Icons.check_circle : Icons.directions_run,
//                     color: isCompleted ? Colors.orange : Colors.black,
//                     size: 28,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:all_new_uniplan/l10n/l10n.dart';
import 'package:all_new_uniplan/models/project_model.dart';
import 'package:all_new_uniplan/models/subProject_model.dart';
import 'package:all_new_uniplan/screens/add_project.dart';
import 'package:all_new_uniplan/screens/add_schedule.dart';
import 'package:all_new_uniplan/screens/add_sub_Project.dart';
import 'package:all_new_uniplan/screens/project_chatbot.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toastification/toastification.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  // ** 상태 변수 **
  bool _isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<int, List<SubProject>> _subProjectList = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final projectService = context.read<ProjectService>();
    final authService = context.read<AuthService>();

    setState(() {
      _isLoading = true;
    });

    try {
      await projectService.getProjectByUserId(authService.currentUser!.userId);
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text(context.l10n.loadProjectsFailed),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSubProjectByDate() async {
    final projectService = context.read<ProjectService>();
    if (projectService.projects == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<int, List<SubProject>> newSubProjects = {};

      for (final project in projectService.projects!.values) {
        final subProjects = await projectService.getSubProjectByDate(
          project.projectId!,
          _focusedDay,
        );
        if (subProjects.isNotEmpty) {
          newSubProjects[project.projectId!] = subProjects;
        }
      }

      setState(() {
        _subProjectList = newSubProjects;
      });
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text(context.l10n.loadProjectTasksFailed),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onFormatChange(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectService = context.watch<ProjectService>();
    final projects = projectService.projects?.values.toList() ?? [];

    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar(
            currentFormat: _calendarFormat,
            onFormatChanged: _onFormatChange,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar(
                  availableGestures: AvailableGestures.horizontalSwipe,
                  locale: context.l10n.localeName,
                  firstDay: DateTime.utc(2025, 3, 1),
                  lastDay: DateTime.utc(2033, 12, 31),
                  focusedDay: _focusedDay,
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                  daysOfWeekHeight: 35,
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _loadSubProjectByDate();
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      final text = DateFormat.E(
                        context.l10n.localeName,
                      ).format(day);
                      Color textColor =
                          Theme.of(context).colorScheme.onSurfaceVariant;
                      if (day.weekday == DateTime.sunday) {
                        textColor = Colors.red;
                      } else if (day.weekday == DateTime.saturday) {
                        textColor = Colors.blue;
                      }
                      return Center(
                        child: Text(text, style: TextStyle(color: textColor)),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      if (day.weekday == DateTime.sunday ||
                          day.weekday == DateTime.saturday) {
                        return Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color:
                                  day.weekday == DateTime.sunday
                                      ? Colors.red
                                      : Colors.blue,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  (day.weekday == DateTime.sunday)
                                      ? Colors.red
                                      : (day.weekday == DateTime.saturday)
                                      ? Colors.blue
                                      : Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color:
                                  (day.weekday == DateTime.sunday)
                                      ? Colors.red
                                      : (day.weekday == DateTime.saturday)
                                      ? Colors.blue
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                (day.weekday == DateTime.sunday)
                                    ? Colors.red
                                    : (day.weekday == DateTime.saturday)
                                    ? Colors.blue
                                    : Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                for (final project in projects)
                  if (_subProjectList.containsKey(project.projectId))
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 32.0,
                        left: 17,
                        right: 17,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Divider(color: Colors.orange.shade300, thickness: 2),
                          const SizedBox(height: 8),
                          if (_subProjectList[project.projectId!] != null)
                            for (final subProject
                                in _subProjectList[project.projectId!]!)
                              ProjectProgressCard(
                                subProjectId: subProject.subProjectId!,
                                title: subProject.subGoal!,
                                currentStep: subProject.done ?? 0,
                                maxStep: subProject.maxDone ?? 1,
                                multiPerDay: subProject.multiPerDay ?? false,
                                onIncrement: () async {
                                  if ((subProject.done ?? 0) <
                                      (subProject.maxDone ?? 1)) {
                                    final result = await projectService
                                        .addSubProjectProgress(
                                          subProject.subProjectId!,
                                          _focusedDay,
                                        );
                                    if (result) _loadSubProjectByDate();
                                  }
                                },
                                onDecrement: () {
                                  if ((subProject.done ?? 0) > 0) {
                                    projectService.cancelSubProjectProgress(
                                      subProject.subProjectId!,
                                      _focusedDay,
                                    );
                                  }
                                },
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        title: Text(
                                          context.l10n.deleteGoalTitle,
                                        ),
                                        content: Text(
                                          context.l10n.deleteGoalContent(
                                            subProject.subGoal!,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop(),
                                            child: Text(context.l10n.no),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context
                                                  .read<ProjectService>()
                                                  .deleteSubProject(
                                                    project.projectId!,
                                                    subProject.subProjectId!,
                                                  );
                                              Navigator.of(dialogContext).pop();
                                            },
                                            child: Text(
                                              context.l10n.yes,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              )
                          else
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(context.l10n.noSubGoals),
                            ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          floatingActionButton: SpeedDial(
            icon: Icons.add,
            activeIcon: Icons.close,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.android),
                label: context.l10n.projectChatbot,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (pageContext) => const ProjectChatbot(),
                    ),
                  );
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.calendar_today),
                label: context.l10n.planSubGoals,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (pageContext) => const AddSubProject(),
                    ),
                  );
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.add_task),
                label: context.l10n.createProject,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (pageContext) => const AddProject(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: const Color(0x80000000),
            child: Center(
              child: SpinKitFadingCube(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CalendarFormat currentFormat;
  final Function(CalendarFormat) onFormatChanged;

  const CustomAppBar({
    super.key,
    required this.currentFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/logo.png', height: 45),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFormatButton(
                  context,
                  CalendarFormat.month,
                  context.l10n.toggleMonth,
                  currentFormat == CalendarFormat.month,
                ),
                _buildFormatButton(
                  context,
                  CalendarFormat.week,
                  context.l10n.toggleWeek,
                  currentFormat == CalendarFormat.week,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton(
    BuildContext context,
    CalendarFormat format,
    String text,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onFormatChanged(format),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProjectProgressCard extends StatelessWidget {
  final int subProjectId;
  final String title;
  final int currentStep;
  final int maxStep;
  final bool multiPerDay;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const ProjectProgressCard({
    super.key,
    required this.subProjectId,
    required this.maxStep,
    required this.title,
    required this.currentStep,
    required this.multiPerDay,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (maxStep == 0) ? 0.0 : currentStep / maxStep;
    final bool isCompleted = currentStep >= maxStep;

    return Slidable(
      key: ValueKey(subProjectId),
      groupTag: 'sub-project-list',
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: context.l10n.deleteAction,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: InkWell(
        onTap: onIncrement,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onDecrement();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade300, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.orange,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Text(
                    '$currentStep/$maxStep',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.directions_run,
                    color:
                        isCompleted
                            ? Colors.orange
                            : Theme.of(context).colorScheme.onSurface,
                    size: 28,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
