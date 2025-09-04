// ** 20250814 made by 김범식 **

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/chat_message_model_2.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';

class ChatbotService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final ScheduleService _scheduleService;

  ChatbotService(this._scheduleService);

  final List<ChatMessage> _messages = [];
  late ChatMessage _currentMessage;

  List<ChatMessage> get messages => _messages;
  ChatMessage get cureentMessage => _currentMessage;

  // 사용자의 의사(예/아니오)에 따라 처리를 기다리는 일정
  // 일정 추가 요청, 추천 요청
  Schedule? _pendingScheduleAdd;

  // 일정 삭제 요청
  Schedule? _pendingScheduleDelete;

  // 일정 변경 요청
  Schedule? _pendingScheduleOriginal;
  Schedule? _pendingScheduleModify;

  // 외부에서 읽기 전용으로 접근할 getter
  Schedule? get pendingScheduleAdd => _pendingScheduleAdd;
  Schedule? get pendingScheduleDelete => _pendingScheduleDelete;
  Schedule? get pendingScheduleOriginal => _pendingScheduleOriginal;
  Schedule? get pendingScheduleModify => _pendingScheduleModify;

  final bool _isLoading = false;

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessage(String message, int userId) async {
    if (message.trim().isNotEmpty) {
      final Map<String, dynamic> body = {"message": message, "user_id": userId};

      try {
        final response = await _apiClient.post('/chatbot', body: body);
        var json = jsonDecode(response.body);
        var message = json['message'];

        if (message == "Response Success") {
          _currentMessage = ChatMessage(
            message: message,
            speaker: ChatMessageType.user,
            timestamp: DateTime.now(),
            showButtons: false,
          );
          addMessage(_currentMessage);

          var intent = json['intent'];
          var output = json['output'];

          if (intent == "단순 채팅") {
            _currentMessage = ChatMessage(
              message: output,
              speaker: ChatMessageType.user,
              timestamp: DateTime.now(),
              showButtons: false,
            );
          } else if (intent == "일정 추가 요청" || intent == "일정 추천 요청") {
            _pendingScheduleAdd = Schedule.fromJson(output);
            final scheduleInfoText = _currentMessage.scheduleAddMessage(
              _pendingScheduleAdd!,
            );

            _currentMessage = ChatMessage(
              message: scheduleInfoText,
              speaker: ChatMessageType.user,
              timestamp: DateTime.now(),
              showButtons: true,
            );
          } else if (intent == "일정 변경 요청") {
            _pendingScheduleOriginal = Schedule.fromJson(output["add"]);
            _pendingScheduleModify = Schedule.fromJson(output["delete"]);
            final scheduleInfoText = _currentMessage.scheduleModifyMessage(
              _pendingScheduleOriginal!,
              _pendingScheduleModify!,
            );

            _currentMessage = ChatMessage(
              message: scheduleInfoText,
              speaker: ChatMessageType.user,
              timestamp: DateTime.now(),
              showButtons: true,
            );
          } else {
            print('오류: 삭제하려는 스케줄 객체가 null입니다.');
            return;
            // null일 때의 처리
          }
          addMessage(_currentMessage);
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  // 사용자가 '확인'을 눌렀을 때 UI에서 호출할 메서드
  void confirmScheduleAddition(int userId) {
    if (_pendingScheduleAdd != null) {
      try {
        _scheduleService.addSchedule(
          userId,
          _pendingScheduleAdd!.title,
          _pendingScheduleAdd!.date,
          _pendingScheduleAdd!.startTime,
          _pendingScheduleAdd!.endTime,
          location: _pendingScheduleAdd!.location,
          memo: _pendingScheduleAdd!.memo,
          isLongProject: _pendingScheduleAdd!.isLongProject,
        );
        _currentMessage = ChatMessage(
          message: "일정이 정상적으로 추가되었습니다.",
          speaker: ChatMessageType.bot,
          timestamp: DateTime.now(),
          showButtons: false,
        );
        addMessage(_currentMessage);
      } catch (e) {
        rethrow;
      } finally {
        _pendingScheduleAdd = null;
      }
    } else if (_pendingScheduleDelete != null) {
      try {} catch (e) {
        rethrow;
      } finally {
        _pendingScheduleDelete = null;
      }
    } else if (_pendingScheduleOriginal != null) {
      try {
        _scheduleService.modifySchedule(
          userId,
          _pendingScheduleOriginal!,
          _pendingScheduleModify!,
        );

        _currentMessage = ChatMessage(
          message: "일정이 정상적으로 변경되었습니다.",
          speaker: ChatMessageType.bot,
          timestamp: DateTime.now(),
          showButtons: false,
        );
        addMessage(_currentMessage);
      } catch (e) {
        rethrow;
      } finally {
        _pendingScheduleOriginal = null;
        _pendingScheduleModify = null;
      }
    }

    // _addMessage('일정이 추가되었습니다.', ChatMessageType.bot);

    notifyListeners();
  }

  // 사용자가 '취소'를 눌렀을 때 UI에서 호출할 메서드
  void cancelScheduleAddition() {
    _pendingScheduleAdd = null;
    _pendingScheduleDelete = null;
    _pendingScheduleOriginal = null;
    _pendingScheduleModify = null;

    notifyListeners();
  }
}
