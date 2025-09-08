import 'package:all_new_uniplan/utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';

enum ChatMessageType { user, bot }

// 채팅 메시지 내용을 저장하는 클래스
class ChatMessage {
  final String message; // 채팅 내용
  final ChatMessageType speaker; // 화자
  final DateTime timestamp; // 채팅 시간
  bool showButtons; // 예, 아니오 버튼 여부

  ChatMessage({
    required this.message,
    required this.speaker,
    required this.timestamp,
    required this.showButtons,
  });

  String scheduleAddMessage(Schedule addSchedule) {
    final formattedDate = DateFormat('yyyy년 MM월 dd일').format(addSchedule.date);
    final formattedStartTime = formatTime(addSchedule.startTime);
    final formattedEndTime = formatTime(addSchedule.endTime);

    String scheduleInfoText =
        '다음 일정 추가를 확인해주세요:\n\n'
        '제목: ${addSchedule.title}\n'
        '날짜: $formattedDate\n'
        '시간: $formattedStartTime - $formattedEndTime\n'
        '장소: ${addSchedule.location!.isNotEmpty ? addSchedule.location : '미정'}\n';

    return scheduleInfoText;
  }

  String scheduleModifyMessage(
    Schedule originalSchedule,
    Schedule modifySchedule,
  ) {
    final formattedOriginalDate = DateFormat(
      'yyyy년 MM월 dd일',
    ).format(originalSchedule.date);
    final formattedOriginalStartTime = formatTime(originalSchedule.startTime);
    final formattedOriginalEndTime = formatTime(originalSchedule.endTime);

    final formattedModifyDate = DateFormat(
      'yyyy년 MM월 dd일',
    ).format(modifySchedule.date);
    final formattedModifyStartTime = formatTime(modifySchedule.startTime);
    final formattedModifyEndTime = formatTime(modifySchedule.endTime);

    String scheduleInfoText =
        '다음 일정 추가를 확인해주세요:\n\n'
        '#추가#\n'
        '제목: ${modifySchedule.title}\n'
        '날짜: $formattedModifyDate\n'
        '시간: $formattedModifyStartTime - $formattedModifyEndTime\n'
        '장소: ${modifySchedule.location!.isNotEmpty ? modifySchedule.location : '미정'}\n'
        '#삭제#\n'
        '제목: ${originalSchedule.title}\n'
        '날짜: $formattedOriginalDate\n'
        '시간: $formattedOriginalStartTime - $formattedOriginalEndTime\n'
        '장소: ${originalSchedule.location!.isNotEmpty ? originalSchedule.location : '미정'}\n';

    return scheduleInfoText;
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'speaker': speaker == ChatMessageType.user ? "user" : "bot",
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // json 값을 변환하여 자기 자신의 필드를 초기화하고 자신을 반환하는 메서드
  factory ChatMessage.fromJson(dynamic json) {
    var speaker = json['speaker'] as String;
    return ChatMessage(
      message: json['message'] as String,
      speaker: speaker == 'user' ? ChatMessageType.user : ChatMessageType.bot,
      timestamp: DateTime.parse(json['timestamp'] as String),
      showButtons: false,
    );
  }
}
