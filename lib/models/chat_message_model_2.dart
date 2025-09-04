// ** 20250814 made by 김범식 **

import 'package:intl/intl.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';

enum ChatMessageType { user, bot }

class ChatMessage {
  final String message;
  final ChatMessageType speaker;
  final DateTime timestamp;
  final bool showButtons;

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
