// ** 2025 08 09 새로 작업했던 챗봇 화면 by 김범식 **

import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import 'package:all_new_uniplan/services/chatbot_service_2.dart';
import 'package:provider/provider.dart';

Schedule json_to_schedule(var output) {
  int scheduleId = (output["schedule_id"] as num?)?.toInt() ?? 0;
  String title = output["title"] ?? ''; // null 안전 처리
  DateTime date = DateTime.parse(output["date"] ?? ''); // null 안전 처리
  TimeOfDay startTime = TimeOfDay(
    hour: int.parse(
      (output["start_time"] as String?)?.split(":")[0] ?? '0',
    ), // null 안전 및 문자열 처리
    minute: int.parse(
      (output["start_time"] as String?)?.split(":")[1] ?? '0',
    ), // null 안전 및 문자열 처리
  );
  TimeOfDay endTime = TimeOfDay(
    hour: int.parse(
      (output["end_time"] as String?)?.split(":")[0] ?? '0',
    ), // null 안전 및 문자열 처리
    minute: int.parse(
      (output["end_time"] as String?)?.split(":")[1] ?? '0',
    ), // null 안전 및 문자열 처리
  );
  String location = output["location"] ?? ''; // null 안전 처리
  // fatigue_level 파싱 수정: num 타입 캐스팅 후 double로 변환, null일 경우 기본값 0.0
  double fatigueLevel = (output["fatigue_level"] as num?)?.toDouble() ?? 0.0;
  String memo = ""; // 필요에 따라 추가

  // Schedule 객체를 생성하여 currentProposedSchedule에 할당
  Schedule schedule = Schedule(
    schedule_id: scheduleId,
    title: title,
    date: date,
    startTime: startTime,
    endTime: endTime,
    location: location,
    memo: memo,
    fatigue_level: fatigueLevel,
  );

  return schedule;
}

// 일정 변경시 삭제하는 일정의 id를 구하는 함수
int? findScheduleId({
  required String title,
  required DateTime date,
  required TimeOfDay startTime,
}) {
  return null;
}

// ChatMessage 모델 확장: text와 customWidget을 모두 선택적으로 가질 수 있도록 수정
class ChatMessage {
  final String? text; // 텍스트는 선택 사항 (null 허용)
  final Widget? customWidget; // 커스텀 위젯도 선택 사항 (null 허용)
  final String? intent;
  final bool isUser;
  // 새로운 필드 추가: 이 메시지에 버튼을 표시할지 여부
  bool showButtons; // 이 값은 변경될 수 있으므로 final이 아님

  ChatMessage({
    this.text,
    this.customWidget,
    this.intent,
    required this.isUser,
    this.showButtons = false, // 기본값은 버튼 표시 안 함
  }) : assert(
         text != null || customWidget != null, // 둘 중 하나는 반드시 있어야 함
         'Either text or customWidget must be provided for ChatMessage',
       );
}

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  List<ChatMessage> messages = [
    // ** 서버에서 대화 내역을 불러오도록 사양 변경 필요? **
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 서비스 Class의 인스턴스 생성
  late final ScheduleService scheduleService;
  late final ChatbotService chatbotService;
  late final AuthService authService;

  // Schedule 객체를 _ChatPageState의 멤버 변수로 선언
  // '일정 추가 요청' 시 여기에 값을 할당하고, '아니오' 클릭 시 null로 만들 수 있도록 합니다.
  Schedule? currentProposedSchedule; // 현재 제안된 일정 객체

  Schedule? currentAddedSchedule; // 일정 수정 시 추가되는 일정 객체
  Schedule? currentDeletedSchedule; // 일정 수정 시 삭제되는 일정 객체

  // 새로운 함수: 일정 db에 추가
  Future<void> addSchedule(Schedule schedule) async {}

  // // 새로운 함수: 일정 db에 추가
  Future<void> modifySchedule(
    Schedule addSchedule,
    Schedule deleteSchedule,
  ) async {}

  Future<void> sendMessage(String text) async {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Service 인스턴스 생성
    scheduleService = context.read<ScheduleService>();
    chatbotService = context.read<ChatbotService>();
    authService = context.read<AuthService>();
  }

  // 메시지 버블의 내용을 렌더링하는 함수
  Widget buildMessage(ChatMessage message) {
    final isUser = message.isUser;

    // 메시지 내용들을 담을 List
    List<Widget> children = [];

    // 텍스트가 있으면 Text 위젯 추가
    if (message.text != null && message.text!.isNotEmpty) {
      children.add(
        Text(
          message.text!,
          style: TextStyle(color: isUser ? Colors.black : Colors.black),
        ),
      );
    }

    // showButtons이 true인 경우에만 버튼 위젯 추가
    if (message.showButtons) {
      // 텍스트가 있을 경우, 텍스트와 버튼 사이에 간격 추가
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 10));
      }
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 버튼을 가로로 중앙 정렬
          children: [
            ElevatedButton(
              onPressed: () {
                if (message.intent == "일정 추가 요청" ||
                    message.intent == "일정 추천 요청") {
                  print('사용자가 일정 추가를 "예"라고 응답했습니다.');
                  setState(() {
                    // 해당 메시지의 showButtons 상태를 false로 변경하여 버튼 숨기기
                    message.showButtons = false;

                    // currentProposedSchedule이 null이 아니면 addSchedule 호출
                    // addSchedule(currentProposedSchedule!);
                    scheduleService.addScheduleToList(
                      currentProposedSchedule!,
                    ); // !로 non-null 보장
                    messages.add(
                      ChatMessage(text: '일정을 추가합니다.', isUser: false),
                    );
                    // TODO: 여기에 실제 일정 저장 API 호출 로직 추가
                  });
                } else if (message.intent == "일정 변경 요청") {
                  setState(() {
                    // 해당 메시지의 showButtons 상태를 false로 변경하여 버튼 숨기기
                    message.showButtons = false;
                    print(currentAddedSchedule);
                    print(currentDeletedSchedule);

                    // currentProposedSchedule이 null이 아니면 addSchedule 호출
                    if (currentAddedSchedule != null &&
                        currentDeletedSchedule != null) {
                      modifySchedule(
                        currentAddedSchedule!,
                        currentDeletedSchedule!,
                      );
                      scheduleService.modifyScheduleToList(
                        currentAddedSchedule!,
                        currentDeletedSchedule!,
                      ); // !로 non-null 보장
                      messages.add(
                        ChatMessage(text: '일정을 변경합니다.', isUser: false),
                      );
                    } else {
                      messages.add(
                        ChatMessage(text: '일정을 변경하지 않습니다.', isUser: false),
                      );
                    }
                    // TODO: 여기에 실제 일정 저장 API 호출 로직 추가
                  });
                }
              },
              child: const Text('예'),
            ),
            const SizedBox(width: 16), // 버튼 사이 간격
            OutlinedButton(
              onPressed: () {
                print('사용자가 일정 추가를 "아니오"라고 응답했습니다.');
                setState(() {
                  // 해당 메시지의 showButtons 상태를 false로 변경하여 버튼 숨기기
                  message.showButtons = false;

                  // currentProposedSchedule을 null로 만들고 응답 메시지 추가
                  currentProposedSchedule = null;
                  messages.add(
                    ChatMessage(text: '일정 추가를 취소합니다.', isUser: false),
                  );
                  // TODO: 일정 취소 로직 추가
                });
              },
              child: const Text('아니오'),
            ),
          ],
        ),
      );
    }

    // 텍스트와 버튼(있다면)을 세로로 정렬
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
      children: children,
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              CircleAvatar(radius: 16, backgroundColor: Colors.black),
            if (!isUser) SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: isUser ? Color(0xEE8CFF1A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: content, // 텍스트와 버튼이 포함된 Column을 여기에 넣습니다.
              ),
            ),
            if (isUser) SizedBox(width: 8),
            if (isUser) CircleAvatar(radius: 16, backgroundColor: Colors.black),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xEEEBF2E8),
      appBar: chatTopBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          // Divider(height: 1),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Row(
              children: [
                // 입력창
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onSubmitted: sendMessage,
                            decoration: const InputDecoration(
                              hintText: '여기에 메시지를 입력...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Icon(Icons.mic_none, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 전송 버튼
                GestureDetector(
                  onTap: () => sendMessage(_controller.text),
                  // () => {
                  //   chatbotService.sendMessage(
                  //     _controller.text,
                  //     authService.currentUser!.userId,
                  //   ),

                  //   _controller.text = "",
                  // },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF22553D), // 초록색 배경
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ** 챗봇 화면의 상단 바 **
class chatTopBar extends StatelessWidget implements PreferredSizeWidget {
  const chatTopBar({super.key});

  void _showHelpDialog() {}

  void _showSearchDialog() {}

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // 기본 뒤로가기 제거
      elevation: 0, // 그림자 높이
      scrolledUnderElevation: 0, // 스크롤 해도 색상이 변하지 않게
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '유니봇 1.0',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '도움말',
            onPressed: _showHelpDialog,
            padding: EdgeInsets.zero, // 버튼 내부 간격 최소화
            constraints: const BoxConstraints(), // 아이콘 크기 줄이기
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: '검색',
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
