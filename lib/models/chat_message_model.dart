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

    String scheduleInfoText =
        '다음 일정 추가를 확인해주세요:\n\n'
        '제목: ${addSchedule.title}\n'
        '날짜: $formattedDate\n'
        '시간: ${addSchedule.startTime} - ${addSchedule.endTime}\n'
        '장소: ${addSchedule.location!.isNotEmpty ? addSchedule.location : '미정'}\n'
        '피로도: ${addSchedule.fatigue_level}\n';

    return scheduleInfoText;
  }

  String scheduleModifyMessage(
    Schedule originalSchedule,
    Schedule modifySchedule,
  ) {
    final formattedOriginalDate = DateFormat(
      'yyyy년 MM월 dd일',
    ).format(originalSchedule.date);

    final formattedModifyDate = DateFormat(
      'yyyy년 MM월 dd일',
    ).format(modifySchedule.date);

    String scheduleInfoText =
        '다음 일정 추가를 확인해주세요:\n\n'
        '#추가#\n'
        '제목: ${originalSchedule.title}\n'
        '날짜: $formattedOriginalDate\n'
        '시간: ${originalSchedule.startTime} - ${originalSchedule.endTime}\n'
        '장소: ${originalSchedule.location!.isNotEmpty ? originalSchedule.location : '미정'}\n'
        '#삭제#\n'
        '제목: ${modifySchedule.title}\n'
        '날짜: $formattedModifyDate\n'
        '시간: ${modifySchedule.startTime} - ${modifySchedule.endTime}\n'
        '장소: ${modifySchedule.location!.isNotEmpty ? modifySchedule.location : '미정'}\n';

    return scheduleInfoText;
  }
}
