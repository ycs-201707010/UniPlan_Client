import 'package:all_new_uniplan/models/subProject_model.dart';
import 'package:all_new_uniplan/utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/models/project_model.dart';

enum ProjectChatMessageType { user, bot }

// 채팅 메시지 내용을 저장하는 클래스
class ProjectChatMessage {
  // int logId;
  final String message; // 채팅 내용
  final ProjectChatMessageType speaker; // 화자
  final DateTime timestamp; // 채팅 시간
  bool showButtons; // 예, 아니오 버튼 여부

  ProjectChatMessage({
    required this.message,
    required this.speaker,
    required this.timestamp,
    required this.showButtons,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'speaker': speaker == ProjectChatMessageType.user ? "user" : "bot",
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // json 값을 변환하여 자기 자신의 필드를 초기화하고 자신을 반환하는 메서드
  factory ProjectChatMessage.fromJson(dynamic json) {
    var speaker = json['speaker'] as String;
    return ProjectChatMessage(
      message: json['message'] as String,
      speaker:
          speaker == 'user'
              ? ProjectChatMessageType.user
              : ProjectChatMessageType.bot,
      timestamp: DateTime.parse(json['timestamp'] as String),
      showButtons: false,
    );
  }

  String projectAddMessage(Project addProject) {
    final formattedStartDate = formatDate(addProject.startDate);
    final formattedEndDate = formatDate(addProject.endDate);

    String projectInfoText =
        '다음 프로젝트 추가를 확인해주세요:\n\n'
        '# 프로젝트 정보\n'
        '제목: ${addProject.title}\n'
        '목표: ${addProject.goal}\n'
        '종류: ${addProject.project_type}\n'
        '기간: $formattedStartDate - $formattedEndDate\n\n'
        '- 하위 프로젝트 정보\n';

    int i = 1;
    String beforeSubGoal = "";
    int beforeMaxDone = -1;
    String weekday = "";

    // 리스트의 총 길이와 현재 인덱스를 비교하기 위해 .asMap().entries 사용
    for (final entry in addProject.subProjects!.asMap().entries) {
      final index = entry.key;
      final subProject = entry.value;

      // 1. 새 그룹이 시작되었는지 확인 (첫 번째 항목이거나, goal/maxDone이 변경된 경우)
      if (beforeSubGoal.isEmpty || // 첫 번째 항목
          beforeSubGoal != subProject.subGoal! || // Goal이 변경
          beforeMaxDone != subProject.maxDone!) {
        // MaxDone이 변경

        // 2. (첫 번째 항목이 아닌 경우) 이전 그룹의 정보를 처리(출력)
        if (beforeSubGoal.isNotEmpty) {
          // 누적된 요일 문자열의 마지막 쉼표 제거 (예: "월,화," -> "월,화")
          if (weekday.isNotEmpty) {
            weekday = weekday.substring(0, weekday.length - 1);
          }

          final subProjectInfoText =
              '${i}번 일정.\n'
              '목표: $beforeSubGoal\n' // 이전 그룹의 Goal 사용
              '목표 수행 횟수: $beforeMaxDone\n' // 이전 그룹의 MaxDone 사용
              '요일: [${weekday} 요일]\n\n';
          projectInfoText += subProjectInfoText;
          i++; // 그룹이 끝날 때마다 번호 증가
        }

        // 3. 새 그룹을 위해 변수 초기화
        beforeSubGoal = subProject.subGoal!;
        beforeMaxDone = subProject.maxDone!;
        weekday = weekdayESMap[subProject.weekDay]! + ","; // 새 그룹의 첫 요일 추가
      } else {
        // 4. (같은 그룹인 경우) 현재 요일만 누적
        weekday += weekdayESMap[subProject.weekDay]! + ",";
      }

      // 5. 루프의 마지막 항목인지 확인
      if (index == addProject.subProjects!.length - 1) {
        // 마지막 항목까지 처리한 후, 누적된 마지막 그룹의 정보를 처리(출력)
        if (weekday.isNotEmpty) {
          weekday = weekday.substring(0, weekday.length - 1);
        }
        final subProjectInfoText =
            '${i}번 일정.\n'
            '목표: $beforeSubGoal\n'
            '목표 수행 횟수: $beforeMaxDone\n'
            '요일: [${weekday}요일]\n\n';
        projectInfoText += subProjectInfoText;
      }
    }

    return projectInfoText;
  }
}
