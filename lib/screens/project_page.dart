import 'package:all_new_uniplan/l10n/l10n.dart';
import 'package:all_new_uniplan/models/project_model.dart';
import 'package:all_new_uniplan/models/subProject_model.dart';
import 'package:all_new_uniplan/screens/add_project.dart';
import 'package:all_new_uniplan/screens/add_schedule.dart';
import 'package:all_new_uniplan/screens/add_sub_Project.dart';
import 'package:all_new_uniplan/screens/project_chatbot.dart';
import 'package:all_new_uniplan/screens/project_stats_page.dart';
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

        for (final subProject in subProjects) {
          print(subProject.subGoal);
          print(subProject.done);
        }
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                project.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  // TODO : 프로젝트 타입(공부, 운동 등)에 따라 색상 변경하기
                                  color: Colors.orange,
                                ),
                              ),

                              // TODO : 수정하기 버튼으로 구현
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.edit),
                              ),
                            ],
                          ),
                          Divider(color: Colors.orange.shade300, thickness: 2),
                          const SizedBox(height: 8),
                          if (_subProjectList[project.projectId!] != null)
                            for (final subProject
                                in _subProjectList[project.projectId!]!)
                              // 하위 프로젝트를 하나씩 카드로 표시
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
                child: const Icon(Icons.bar_chart_rounded),
                label: context.l10n.projectStatView,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (pageContext) => const ProjectStatsPage(),
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
    // ✅ 1. 현재 테마의 밝기를 확인합니다.
    final brightness = Theme.of(context).brightness;

    // ✅ 2. 밝기에 따라 사용할 로고 이미지 경로를 결정합니다.
    final String logoPath =
        (brightness == Brightness.dark)
            ? 'assets/images/logo_dark.png' // 다크 모드일 때 (배경이 어두울 때)
            : 'assets/images/logo.png'; // 라이트 모드일 때 (배경이 밝을 때) // 로고 이미지를 가져올 디렉터리 주소

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(logoPath, height: 45),
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: '도움말',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      // 상단 모서리를 둥글게
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // ✅ 내용의 높이만큼만 차지
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '프로젝트 도움말',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text('프로젝트의 하위 목표까지 생성하셨나요? 이제 진척도를 올려볼 차례입니다.'),
                            SizedBox(height: 10),
                            Text('터치하면 진척도가 올라갑니다.'),
                            Text('길게 누르면 진척도가 내려갑니다.'),
                            SizedBox(height: 10),
                            Text(
                              '오른쪽에서 왼쪽으로 목표를 잡고 슬라이드하면, 수정과 삭제 버튼을 보실 수 있습니다.',
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
                padding: EdgeInsets.zero, // 버튼 내부 간격 최소화
                constraints: const BoxConstraints(), // 아이콘 크기 줄이기
              ),
            ],
          ),
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

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Slidable(
          key: ValueKey(subProjectId),
          groupTag: 'sub-project-list',
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.4,
            children: [
              SlidableAction(
                onPressed: (context) => {},
                backgroundColor: const Color(0xFF21B7CA),
                foregroundColor: Colors.white,
                label: '수정',
              ),
              SlidableAction(
                onPressed: (context) => onDelete(),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: context.l10n.deleteAction,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
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
              padding: const EdgeInsets.all(16.0),

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
        ),
      ),
    );
  }
}
