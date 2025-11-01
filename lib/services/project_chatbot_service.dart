import 'dart:convert';
import 'package:all_new_uniplan/services/project_service.dart';
import 'package:all_new_uniplan/services/subProject_service.dart';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/api/api_client.dart';
import 'package:all_new_uniplan/models/subProject_model.dart';
import 'package:all_new_uniplan/models/project_model.dart';
import 'package:all_new_uniplan/models/project_chat_message_model.dart';

class ProjectChatbotService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final ProjectService _projectService;

  ProjectChatbotService(this._projectService);

  // sendType 변수 ("운동", "공부")
  String _sendType = "운동"; // 기본값
  String get sendType => _sendType;

  // 채팅 내역을 담는 List 변수
  final List<ProjectChatMessage> _messages = [];
  List<ProjectChatMessage> get messages => _messages;

  // 가장 마지막 채팅에 해당하는 클래스가 저장되는 변수
  late ProjectChatMessage _currentMessage;
  ProjectChatMessage get currentMessage => _currentMessage;

  // 사용자의 의사(예/아니오)에 따른 처리를 기다리는 일정
  // 프로젝트 추천 요청 시의 챗봇이 답변한 일정 정보를 임시로 저장하는 변수
  Project? _pendingProjectAdd;

  // 외부에서 읽기 전용으로 접근할 getter
  Project? get pendingProjectAdd => _pendingProjectAdd;

  // LLM 모델이 응답을 생성 중인지 나타내는 상태 변수
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 'sendType'을 변경하고, 변경 사항을 구독자(widget)에게 알리는 메서드
  void setSendType(String newType) {
    if (_sendType != newType) {
      //
      _sendType = newType;
      print("Service sendType updated to: $_sendType");
      notifyListeners(); // 👈 이것이 핵심! UI를 갱신하라고 알립니다.
    }
  }

  // 매개변수로 전달받은 채팅 클래스를 채팅 내역을 저장하는 List 필드에 추가
  void addMessage(ProjectChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  // 입력받은 메시지를 서버 측에 전송하고 사용자의 채팅 의도에 따른
  // 챗봇의 대답을 변환하여 메시지를 생성하고 채팅 내역을 갱신하는 함수
  Future<void> sendMessage(
    String message,
    String projectType,
    int userId,
  ) async {
    // 사용자가 입력한 내용이 존재하는 경우에 한해 진행
    if (message.trim().isNotEmpty) {
      // 가장 마지막 채팅을 사용자가 입력한 채팅으로 갱신하고 채팅 내역을 저장하는 필드에 추가한다.
      _currentMessage = ProjectChatMessage(
        message: message,
        speaker: ProjectChatMessageType.user,
        timestamp: DateTime.now(),
        showButtons: false,
      );

      addMessage(_currentMessage);

      // LLM 모델에 메시지를 전송하기 전에, isTyping을 true로 전환.
      _isLoading = true;
      notifyListeners(); // UI에 '입력 중' 애니메이션을 표시하도록 알림

      final Map<String, dynamic> body = {
        "user_id": userId,
        "project_type": projectType,
        "message": ChatHistoryToJson(),
      };

      try {
        final response = await _apiClient.post(
          '/chatbot/projectChat',
          body: body,
        );
        var json = jsonDecode(response.body);
        var message = json['message'];

        // 정상적으로 서버로부터 응답받은 경우
        if (message == "Response Successed") {
          var intent = json['intent'];
          var output = json['output'];

          // 챗봇이 판단한 사용자의 입력 의도가 단순 채팅 or 프로젝트 질문인 경우
          // 가장 마지막 채팅을 챗봇의 대답으로 갱신한다.
          if (intent == "단순 채팅" || intent == "프로젝트 질문") {
            _currentMessage = ProjectChatMessage(
              message: output,
              speaker: ProjectChatMessageType.bot,
              timestamp: DateTime.now(),
              showButtons: false,
            );
          } else if (intent == "프로젝트 생성") {
            final projectJson = Map<String, dynamic>.from(output["project"]);
            _pendingProjectAdd = Project.fromJson(projectJson);

            final subProjectJsonList = output["sub_projects"] as List<dynamic>;

            for (var subProjectJson in subProjectJsonList) {
              subProjectJson = subProjectJson as Map<String, dynamic>;
              final weekDays = subProjectJson['weekdays'] as List<dynamic>;

              for (final weekDay in weekDays) {
                final subProject = SubProject(
                  subProjectId: subProjectJson['subproject_id'] as int?,
                  subGoal: subProjectJson['goal'] as String?,
                  done: subProjectJson['done'] as int?,
                  maxDone: subProjectJson['max_done'] as int?,
                  weekDay: weekdaySEMap[(weekDay as String).trim()],
                  multiPerDay: false,
                  color: subProjectJson['color'] as String?,
                );
                _pendingProjectAdd!.addSubProjectToList(subProject);
              }
            }

            final projectInfoText = _currentMessage.projectAddMessage(
              _pendingProjectAdd!,
            );
            // 이때 showButtons을 true로 지정하여 말풍선 생성 시
            // 예, 아니오 버튼을 통해 사용자의 입력을 받을 수 있도록 한다.
            _currentMessage = ProjectChatMessage(
              message: projectInfoText,
              speaker: ProjectChatMessageType.bot,
              timestamp: DateTime.now(),
              showButtons: true,
            );
          } else {
            print('챗봇이 응답을 생성하는 과정에서 에러 발생');
            throw Exception('Response Failed: $message');
            // return;
            // null일 때의 처리
          }

          // 위의 if문을 통해 갱신된 마지막 채팅을 채팅 내역에 저장한다.
          addMessage(_currentMessage);
        }
      } catch (e) {
        print("챗봇이 응답을 생성하는 과정에서 에러 발생");
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

    if (_pendingProjectAdd != null) {
      try {
        _projectService.addProjectAndSubProjectByLLM(
          _pendingProjectAdd!,
          userId,
        );

        _currentMessage = ProjectChatMessage(
          message: "프로젝트가 정상적으로 추가되었습니다.",
          speaker: ProjectChatMessageType.bot,
          timestamp: DateTime.now(),
          showButtons: false,
        );
      } catch (e) {
        _currentMessage = ProjectChatMessage(
          message: "프로젝트를 추가하는데 실패했습니다.",
          speaker: ProjectChatMessageType.bot,
          timestamp: DateTime.now(),
          showButtons: false,
        );
        rethrow;
      } finally {
        addMessage(_currentMessage);
        _pendingProjectAdd = null;
      }
    }
    // 상태 변화를 알려 해당 클래스를 구독 중인 부분을 build한다.
    notifyListeners();
  }

  // 사용자가 '취소'를 눌렀을 때 UI에서 호출할 메서드로
  // 각 임시 변수를 초기화하고 취소 관련 메시지를 생성하여
  // 마지막 채팅과 채팅 내역을 저장하는 필드를 갱신한다.
  void cancelScheduleAddition() {
    _pendingProjectAdd = null;
    _messages.last.showButtons = false;

    _currentMessage = ProjectChatMessage(
      message: "프로젝트를 추가하지 않습니다.",
      speaker: ProjectChatMessageType.bot,
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
              chatMessage.speaker == ProjectChatMessageType.user
                  ? 'user'
                  : 'assistant';

          // 3. API가 요구하는 형식의 Map을 생성하여 반환
          return {'role': role, 'content': chatMessage.message};
        }).toList(); // map의 결과를 다시 List로 만듦

    // 4. List<Map>을 최종 JSON 문자열로 인코딩
    return jsonEncode(messageListForJson);
  }

  void clearMessages() {
    _messages.clear();
  }
}
