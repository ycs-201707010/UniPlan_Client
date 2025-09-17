import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/chat_message_model.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';

class ChatbotService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final ScheduleService _scheduleService;

  ChatbotService(this._scheduleService);

  // 채팅 내역을 담는 List 변수
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  // 가장 마지막 채팅에 해당하는 클래스가 저장되는 변수
  late ChatMessage _currentMessage;
  ChatMessage get currentMessage => _currentMessage;

  // 사용자의 의사(예/아니오)에 따른 처리를 기다리는 일정
  // 일정 추가 요청, 추천 요청 시의 챗봇이 답변한 일정 정보를 임시로 저장하는 변수
  Schedule? _pendingScheduleAdd;

  // 일정 삭제 요청 시의 챗봇이 답변한 일정 정보를 임시로 저장하는 변수
  Schedule? _pendingScheduleDelete;

  // 일정 변경 요청 시의 챗봇이 답변한 일정 정보를 임시로 저장하는 변수
  Schedule? _pendingScheduleOriginal;
  Schedule? _pendingScheduleNew;

  // 외부에서 읽기 전용으로 접근할 getter
  Schedule? get pendingScheduleAdd => _pendingScheduleAdd;
  Schedule? get pendingScheduleDelete => _pendingScheduleDelete;
  Schedule? get pendingScheduleOriginal => _pendingScheduleOriginal;
  Schedule? get pendingScheduleNew => _pendingScheduleNew;

  // LLM 모델이 응답을 생성 중인지 나타내는 상태 변수
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getMessage(int userId) async {
    final Map<String, dynamic> body = {"user_id": userId};

    try {
      final response = await _apiClient.post('/chatbot/getMessage', body: body);
      var json = jsonDecode(response.body);
      var message = json['message'];

      if (message == "Get Message Successed") {
        var messagesJson = json['chatHistory'];
        // updateMessageListFromJson(messagesJson);
      } else {
        throw Exception('Get Message Failed: $message');
      }
    } catch (e) {
      print('채팅 내역을 가져오는 과정에서 에러 발생: $e');
      // 잡았던 에러를 다시 밖으로 던져서, 이 함수를 호출한 곳에 알림
      rethrow;
    }
  }

  // 매개변수로 전달받은 채팅 클래스를 채팅 내역을 저장하는 List 필드에 추가
  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  // 입력받은 메시지를 서버 측에 전송하고 사용자의 채팅 의도에 따른
  // 챗봇의 대답을 변환하여 메시지를 생성하고 채팅 내역을 갱신하는 함수
  Future<void> sendMessage(String message, int userId) async {
    // 사용자가 입력한 내용이 존재하는 경우에 한해 진행
    if (message.trim().isNotEmpty) {
      // 가장 마지막 채팅을 사용자가 입력한 채팅으로 갱신하고 채팅 내역을 저장하는 필드에 추가한다.
      _currentMessage = ChatMessage(
        message: message,
        speaker: ChatMessageType.user,
        timestamp: DateTime.now(),
        showButtons: false,
      );
      addMessage(_currentMessage);

      // LLM 모델에 메시지를 전송하기 전에, isTyping을 true로 전환.
      _isLoading = true;
      notifyListeners(); // UI에 '입력 중' 애니메이션을 표시하도록 알림

      final Map<String, dynamic> body = {"message": message, "user_id": userId};
      try {
        final response = await _apiClient.post('/chatbot', body: body);
        var json = jsonDecode(response.body);
        var message = json['message'];

        // 정상적으로 서버로부터 응답받은 경우
        if (message == "Response Successed") {
          var intent = json['intent'];
          var output = json['output'];

          // 챗봇이 판단한 사용자의 입력 의도가 단순 채팅인 경우 가장 마지막 채팅을 챗봇의 대답으로 갱신한다.
          if (intent == "단순 채팅") {
            _currentMessage = ChatMessage(
              message: output,
              speaker: ChatMessageType.bot,
              timestamp: DateTime.now(),
              showButtons: false,
            );

            // 챗봇이 판단한 사용자의 입력 의도가 일정 추가 요청, 일정 추천 요청, 일정 변경 요청 등인 경우
            // 일정의 정보를 임시 변수에 저장하고 상황에 맞는 메시지를 생성하여 가장 마지막 채팅을 갱신한다.
          } else if (intent == "일정 추가 요청" || intent == "일정 추천 요청") {
            final scheduleJson = Map<String, dynamic>.from(output);
            _pendingScheduleAdd = Schedule.fromJson(scheduleJson);
            final scheduleInfoText = _currentMessage.scheduleAddMessage(
              _pendingScheduleAdd!,
            );

            // 이때 showButtons을 true로 지정하여 말풍선 생성 시
            // 예, 아니오 버튼을 통해 사용자의 입력을 받을 수 있도록 한다.
            _currentMessage = ChatMessage(
              message: scheduleInfoText,
              speaker: ChatMessageType.bot,
              timestamp: DateTime.now(),
              showButtons: true,
            );
          } else if (intent == "일정 변경 요청") {
            _pendingScheduleOriginal = Schedule.fromJson(output["delete"]);
            int? scheduleId = _scheduleService.findScheduleId(
              _pendingScheduleOriginal!,
            );
            if (scheduleId != null) {
              _pendingScheduleOriginal = _pendingScheduleOriginal!.copyWith(
                scheduleId: scheduleId,
              );
            }

            _pendingScheduleNew = Schedule.fromJson(output["add"]);
            final scheduleInfoText = _currentMessage.scheduleModifyMessage(
              _pendingScheduleOriginal!,
              _pendingScheduleNew!,
            );

            _currentMessage = ChatMessage(
              message: scheduleInfoText,
              speaker: ChatMessageType.bot,
              timestamp: DateTime.now(),
              showButtons: true,
            );
          } else {
            print('오류: 처리하려는 스케줄 객체가 null입니다.');
            throw Exception('Response Failed: $message');
            // return;
            // null일 때의 처리
          }

          // 위의 if문을 통해 갱신된 마지막 채팅을 채팅 내역에 저장한다.
          addMessage(_currentMessage);
        }
      } catch (e) {
        print("챗봇의 응답 내용을 가져오는 과정에서 에러 발생");
        rethrow;
      } finally {
        // ✅ 3. 응답을 받거나 오류가 발생하면 isLoading을 false로 설정
        _isLoading = false;
        notifyListeners(); // UI에 '입력 중' 애니메이션을 숨기도록 알림
      }
    }
  }

  // 사용자가 '확인'을 눌렀을 때 UI에서 호출할 메서드로
  // 입력 의도에 따른 임시 변수의 초기화 여부를 if 문을 통해
  // 구분하여 상황에 맞는 함수를 호출한다.
  // 이후 상황에 맞는 메시지를 생성하여 마지막 채팅과 채팅 내역을 저장하는 필드를 갱신하고
  // 각 임시 변수를 초기화한다.
  void confirmScheduleAddition(int userId) {
    // 가장 마지막 채팅의 클래스에서 showButtons 필드를 false로 변경하여
    // 예 버튼을 클릭했을 때 예, 아니오 버튼이 사라지도록 지정
    _messages.last.showButtons = false;

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
          _pendingScheduleNew!,
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
        _pendingScheduleNew = null;
      }
    }

    // 상태 변화를 알려 해당 클래스를 구독 중인 부분을 build한다.
    notifyListeners();
  }

  // 사용자가 '취소'를 눌렀을 때 UI에서 호출할 메서드로
  // 각 임시 변수를 초기화하고 취소 관련 메시지를 생성하여
  // 마지막 채팅과 채팅 내역을 저장하는 필드를 갱신한다.
  void cancelScheduleAddition() {
    _pendingScheduleAdd = null;
    _pendingScheduleDelete = null;
    _pendingScheduleOriginal = null;
    _pendingScheduleNew = null;

    _messages.last.showButtons = false;

    _currentMessage = ChatMessage(
      message: "일정의 변경을 반영하지 않습니다.",
      speaker: ChatMessageType.bot,
      timestamp: DateTime.now(),
      showButtons: false,
    );
    addMessage(_currentMessage);

    notifyListeners();
  }

  // 채팅 내역을 하나의 문자열로 변경하는 메서드
  String ChatHistoryToJson() {
    final messageListForJson =
        _messages.map((chatMessage) {
          // speaker(enum)를 role(String)으로 변환
          // 챗봇 API는 보통 'bot' 대신 'assistant' 역할을 사용합니다.
          final role =
              chatMessage.speaker == ChatMessageType.user
                  ? 'user'
                  : 'assistant';

          // 3. API가 요구하는 형식의 Map을 생성하여 반환
          return {'role': role, 'content': chatMessage.message};
        }).toList(); // map의 결과를 다시 List로 만듦

    // 4. List<Map>을 최종 JSON 문자열로 인코딩
    return jsonEncode(messageListForJson);
  }

  void updateMessageListFromJson(dynamic messagesJson) {
    // 기존 목록을 비움
    _messages.clear();
    final messagesMap = messagesJson as Map;
    // 맵을 반복하며 모델의 fromJson 생성자를 사용
    messagesMap.forEach((key, value) {
      final message = ChatMessage.fromJson(value as Map<String, dynamic>);
      _messages.add(message);
    });

    // 마지막에 currentMessage 지정

    // UI에 변경사항 알림
    notifyListeners();
  }
}
