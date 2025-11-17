import 'package:all_new_uniplan/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:all_new_uniplan/models/project_model.dart';
import 'package:all_new_uniplan/models/subProject_model.dart';
import 'package:all_new_uniplan/models/project_stat_model.dart';

import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/project_service.dart';

import 'package:percent_indicator/percent_indicator.dart'; // (원형 차트 패키지)

import 'package:all_new_uniplan/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ===============================================
// 📊 통계 페이지 (ProjectStatsPage)
// ===============================================
class ProjectStatsPage extends StatefulWidget {
  const ProjectStatsPage({super.key});

  @override
  State<ProjectStatsPage> createState() => _ProjectStatsPageState();
}

class _ProjectStatsPageState extends State<ProjectStatsPage> {
  // ** 상태 변수 정의 **
  bool _isLoading = true; // 프로젝트 목록 로딩
  List<Project> _projectList = []; // 프로젝트 전체 목록

  Project? _selectedProject; // 현재 선택된 프로젝트
  Stat? _currentStat; // 현재 표시 중인 통계
  bool _isStatLoading = false; // 통계 차트 로딩

  String _currentFilter = 'total'; // 현재 날짜 필터 (total, week, month)

  @override
  void initState() {
    super.initState();
    // 페이지 입장 시 프로젝트 목록을 불러옴
    _loadProjectListFromService();
  }

  // 프로젝트 목록을 API에서 가져옵니다.
  void _loadProjectListFromService() {
    setState(() => _isLoading = true);

    try {
      // 'read'로 Service의 'projects' 맵을 바로 가져옵니다. (통계 페이지를 열기 전, 이미 프로젝트 목록을 가져왔기 때문.)
      final projects =
          context.read<ProjectService>().projects?.values.toList() ?? [];

      setState(() {
        _projectList = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("프로젝트 목록 로드 실패: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('프로젝트 목록 로드 실패: $e')));
    }
  }

  /// (2) 프로젝트를 선택(클릭)했을 때 호출됩니다.
  Future<void> _onProjectSelected(Project project) async {
    setState(() {
      _selectedProject = project;
      _currentFilter = 'total'; // 필터를 '전체'로 초기화
      _currentStat = null; // 차트 초기화
    });
    // ✅ 2. 프로젝트의 '전체 기간'으로 통계를 불러옵니다.
    _fetchStats(project, project.startDate, project.endDate);
  }

  /// (3) 날짜 필터 버튼을 눌렀을 때 호출됩니다.
  Future<void> _onFilterChanged(String filter) async {
    if (_selectedProject == null) return; // 선택된 프로젝트가 없으면 무시

    setState(() {
      _currentFilter = filter; // UI 갱신
      _currentStat = null; // 차트 초기화
    });

    DateTime now = DateTime.now();
    DateTime startDate, endDate;

    if (filter == 'week') {
      startDate = now.subtract(Duration(days: now.weekday - 1)); // 이번 주 월요일
      endDate = startDate.add(Duration(days: 6)); // 이번 주 일요일
    } else if (filter == 'month') {
      startDate = DateTime(now.year, now.month, 1); // 이번 달 1일
      endDate = DateTime(now.year, now.month + 1, 0); // 이번 달 말일
    } else {
      // 'total'
      startDate = _selectedProject!.startDate;
      endDate = _selectedProject!.endDate;
    }

    _fetchStats(_selectedProject!, startDate, endDate);
  }

  /// (4) "직접 선택" 버튼을 눌렀을 때 호출되는 날짜 범위 선택기
  Future<void> _showCustomDateRangePicker() async {
    // 프로젝트가 선택되지 않았으면 아무것도 하지 않음
    if (_selectedProject == null) return;

    // 1. 팝업의 초기 날짜 범위를 설정합니다.
    // (현재 필터가 '주'나 '월'이면 해당 범위를, 아니면 프로젝트 전체 기간을 보여줍니다)
    DateTimeRange initialRange;
    DateTime now = DateTime.now();

    if (_currentFilter == 'week') {
      final start = now.subtract(Duration(days: now.weekday - 1));
      final end = start.add(const Duration(days: 6));
      initialRange = DateTimeRange(start: start, end: end);
    } else if (_currentFilter == 'month') {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      initialRange = DateTimeRange(start: start, end: end);
    } else {
      // 'total' 또는 'custom' 상태일 때
      initialRange = DateTimeRange(
        start: _selectedProject!.startDate,
        end: _selectedProject!.endDate,
      );
    }

    // 2. Flutter의 기본 날짜 범위 선택기(Date Range Picker)를 띄웁니다.
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      // ✅ 선택 가능한 날짜를 프로젝트의 시작일과 종료일로 제한
      firstDate: _selectedProject!.startDate,
      lastDate: _selectedProject!.endDate,
      helpText: '조회할 기간을 선택하세요',
      cancelText: '취소',
      confirmText: '확인',
    );

    // 3. 사용자가 날짜 범위를 선택하고 '확인'을 눌렀다면 (null이 아니라면)
    if (pickedRange != null) {
      // ✅ 4. 'custom'으로 필터 상태를 변경하고,
      setState(() {
        _currentFilter = 'custom';
      });
      // ✅ 5. 선택된 범위로 통계 API를 새로 호출합니다.
      _fetchStats(_selectedProject!, pickedRange.start, pickedRange.end);
    }
  }

  /// API를 호출하여 통계(Stat)를 가져오는 공통 함수
  Future<void> _fetchStats(
    Project project,
    DateTime start,
    DateTime end,
  ) async {
    setState(() => _isStatLoading = true);
    try {
      final stat = await context.read<ProjectService>().getProjectStats(
        project.projectId!,
        start,
        end,
      );
      setState(() {
        _currentStat = stat;
        _isStatLoading = false;
      });
    } catch (e) {
      setState(() => _isStatLoading = false);
      // TODO: 에러 처리 (Toast 넣으면 되려나)
      print("통계 로드 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: context.l10n.projectStat),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // 1. 프로젝트 목록 로딩
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. 프로젝트 선택 드롭다운 ---
                  _buildProjectSelector(),

                  const Divider(height: 1),

                  // --- 3. 날짜 필터 버튼 ---
                  // (프로젝트가 선택되었을 때만 보임)
                  if (_selectedProject != null) _buildDateFilterButtons(),

                  // --- 2. 통계 차트 영역 ---
                  Expanded(
                    child:
                        _isStatLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _currentStat != null
                            ? ProjectStatCard(statData: _currentStat!)
                            : const Center(
                              child: Text(
                                '프로젝트를 선택해주세요.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                  ),
                ],
              ),
    );
  }

  /// (1) 프로젝트 선택 드롭다운 위젯
  Widget _buildProjectSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Project>(
          isExpanded: true,
          hint: Text(context.l10n.projectSelect),
          value: _selectedProject,
          // ✅ 2. 프로젝트를 클릭(변경)하면 _onProjectSelected 호출
          onChanged: (Project? project) {
            if (project != null) {
              _onProjectSelected(project);
            }
          },
          items:
              _projectList.map((Project project) {
                return DropdownMenuItem<Project>(
                  value: project,
                  child: Text(
                    project.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  /// (3) 날짜 필터 버튼 위젯
  Widget _buildDateFilterButtons() {
    return Padding(
      // ✅ 1. Wrap 위젯으로 변경 (자동 줄바꿈)
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Wrap(
        spacing: 12.0, // 버튼 사이의 가로 간격
        runSpacing: 8.0, // 줄바꿈 시 세로 간격
        alignment: WrapAlignment.center, // 가운데 정렬
        children: [
          FilterButton(
            text: context.l10n.statAll,
            isSelected: _currentFilter == 'total',
            onPressed: () => _onFilterChanged('total'),
          ),
          FilterButton(
            text: context.l10n.statWeek,
            isSelected: _currentFilter == 'week',
            onPressed: () => _onFilterChanged('week'),
          ),
          FilterButton(
            text: context.l10n.statMonth,
            isSelected: _currentFilter == 'month',
            onPressed: () => _onFilterChanged('month'),
          ),

          // ✅ 2. "직접 선택" 버튼 추가
          FilterButton(
            text: context.l10n.statCustom,
            isSelected: _currentFilter == 'custom',
            onPressed: _showCustomDateRangePicker, // 👈 1번에서 만든 함수 연결
          ),
        ],
      ),
    );
  }
}

// ===============================================
// 📊 통계 차트 위젯 (지난번 예시)
// ===============================================
class ProjectStatCard extends StatelessWidget {
  final Stat statData;
  const ProjectStatCard({super.key, required this.statData});

  @override
  Widget build(BuildContext context) {
    final double percent = statData.percent / 100;
    final String percentText = "${statData.percent.toStringAsFixed(0)}%";
    final String countText =
        "${statData.completeTask} / ${statData.totalTask}${context.l10n.statComplete}";

    return Center(
      // 카드를 가운데 정렬
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularPercentIndicator(
          radius: 110.0,
          lineWidth: 15.0,
          percent: percent,
          center: Text(
            percentText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          footer: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              countText,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          progressColor: Theme.of(context).colorScheme.primary,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 800,
        ),
      ),
    );
  }
}

// ===============================================
// 🔘 필터 버튼 위젯 (내부 사용)
// ===============================================
class FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainer,
        foregroundColor:
            isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Text(text),
    );
  }
}
