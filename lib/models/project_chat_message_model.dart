import 'package:all_new_uniplan/utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';

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
}
