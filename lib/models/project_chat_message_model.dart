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
    for (final subProject in addProject.subProjects!) {
      final subProjectInfoText =
          '${i}번 일정.\n'
          '목표: ${subProject.subGoal}\n'
          '목표 수행 횟수: ${subProject.maxDone}\n'
          '요일: ${weekdayESMap[subProject.weekDay]}요일\n\n';
      projectInfoText += subProjectInfoText;
      i++;
    }

    return projectInfoText;
  }
}
