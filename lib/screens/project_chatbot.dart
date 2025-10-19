// ** 현재 사용중인 챗봇 페이지 코드 **

import 'package:all_new_uniplan/services/record_service.dart';
import 'package:all_new_uniplan/widgets/recording_bottom_sheet.dart';
import 'package:all_new_uniplan/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:all_new_uniplan/models/project_chat_message_model.dart';
import 'package:all_new_uniplan/services/auth_service.dart';
import 'package:all_new_uniplan/services/project_chatbot_service.dart';

class ProjectChatbot extends StatefulWidget {
  const ProjectChatbot({super.key});

  @override
  State<ProjectChatbot> createState() => _ChatPageState();
}

class _ChatPageState extends State<ProjectChatbot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Schedule 객체를 _ChatPageState의 멤버 변수로 선언
  // '일정 추가 요청' 시 여기에 값을 할당하고, '아니오' 클릭 시 null로 만들 수 있도록 합니다.

  // 채팅의 내용을 UI에 말풍선 형태로 띄우는 함수
  // 매개변수 : 입력한 or 챗봇이 출력하는 채팅 내용을 담은 클래스
  Widget buildMessage(ProjectChatMessage chatMessage) {
    // 말풍선 형태의 위젯들이 저장될 List
    List<Widget> children = [];

    // 매개변수로 전달받은 클래스에서 채팅 내용에 관한 필드가
    // 비어있지 않은 경우 위젯에 말풍선(Text 위젯)을 생성한다.
    if (chatMessage.message.isNotEmpty) {
      children.add(
        Text(
          chatMessage.message,

          // 채팅 내용은 전부 검은색으로 지정.
          style: TextStyle(
            color: // 메시지 화자에 따라 배경색을 다르게 지정
                chatMessage.speaker != ProjectChatMessageType.user
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    }

    // 매개변수로 전달받은 클래스에서 버튼 표시 여부에 대한
    // 필드인 showButtons이 true인 경우에만 버튼 위젯 추가
    if (chatMessage.showButtons) {
      // 채팅 내역이 담긴 List인 children에 텍스트가 있을 경우,
      // 위 말풍선과 새로 생성할 말풍선 사이에 여백을 추가한다.
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 10));
      }
      children.add(
        // Row 위젯에 '예' 버튼과 '아니오' 버튼을 생성한다.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // '예' 버튼
            ElevatedButton(
              onPressed: () {
                // 각 Service 클래스를 구독하는 변수 선언
                final projectChatbotService =
                    context.read<ProjectChatbotService>();
                final authService = context.read<AuthService>();

                // '예' 버튼을 클릭하면 실행되는 메서드로
                // 일정 변경이 반영되었다는 메시지를 생성한다.
                projectChatbotService.confirmScheduleAddition(
                  authService.currentUser!.userId,
                );
              },
              child: const Text('예'),
            ),
            const SizedBox(width: 16), // 버튼 사이 간격
            // '아니오' 버튼
            ElevatedButton(
              onPressed: () {
                final projectChatbotService =
                    context.read<ProjectChatbotService>();

                // '아니오' 버튼을 클릭하면 실행되는 메서드로
                // 일정 변경을 취소한다는 메시지를 생성한다.
                projectChatbotService.cancelScheduleAddition();
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

    // 최종적으로 위젯 내에서의 정렬과 관련한 Align을 반환
    return Align(
      // 만약 화자가 사용자인 경우 오른쪽, 챗봇인 경우 왼쪽 정렬
      alignment:
          // Row 내부 위젯들의 세로 정렬 방식 설정 (프로필 사진과 말풍선의 상단을 맞춤)
          chatMessage.speaker == ProjectChatMessageType.user
              ? Alignment
                  .centerRight // 사용자 메시지는 오른쪽 끝으로 정렬
              : Alignment.centerLeft, // 챗봇 메시지는 왼쪽 시작점으로 정렬
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment:
              chatMessage.speaker == ProjectChatMessageType.user
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 만약 화자가 챗봇인 경우 프로필(임시)에 해당하는 원을 생성
                if (chatMessage.speaker == ProjectChatMessageType.bot)
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(
                      'assets/images/project_profile_pic.png',
                    ),
                  ),
                if (chatMessage.speaker == ProjectChatMessageType.bot)
                  // 프로필과 말풍선 사이의 여백을 생성
                  SizedBox(width: 6),

                if (chatMessage.speaker == ProjectChatMessageType.bot)
                  Text(
                    'UniBot',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            // 말풍선이 화면 너비를 넘어가지 않도록 ConstrainedBox 위젯으로 감싸 말풍선의 최대 크기를 제한.
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              child: Container(
                margin: EdgeInsets.only(left: 12),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color:
                      // 메시지 화자에 따라 배경색을 다르게 지정
                      chatMessage.speaker != ProjectChatMessageType.user
                          ? Theme.of(context).colorScheme.surfaceContainer
                          : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: content, // 텍스트와 버튼이 포함된 Column을 여기에 넣습니다.
              ),
            ),

            // 사용자의 메시지라면 말풍선 오른쪽에 여백을 생성
            if (chatMessage.speaker != ProjectChatMessageType.user)
              SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // 사용자가 메시지를 보내거나, LLM 모델로부터 응답을 받을 때 자동으로 스크롤을 해주는 함수.
  void _scrollToBottom() {
    // 스크롤 컨트롤러가 리스트에 연결되어 있고, 스크롤할 내용이 있을 때만 실행
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // 가장 아래 스크롤 위치
        duration: const Duration(milliseconds: 300), // 0.3초 동안 애니메이션
        curve: Curves.easeOut, // 부드럽게 끝나는 효과
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 ChatbotService와 AuthService의 상태를 구독
    // 서비스의 데이터가 변경되면(notifyListeners 호출 시) 이 위젯은 자동으로 다시 빌드
    final projectChatbotService = context.watch<ProjectChatbotService>();
    final authService = context.watch<AuthService>();
    final recordService = context.watch<RecordService>();
    // final projectChatbotService = context.watch<ProjectChatbotService>();

    // 화면이 다시 그려질 때마다 스크롤을 맨 아래로 내리도록 예약
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      appBar: chatTopBar(),
      body: Column(
        children: [
          Expanded(
            // 스크롤이 가능한 리스트를 생성
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  projectChatbotService.messages.length +
                  (projectChatbotService.isLoading ? 1 : 0),

              // 각 항목이 화면에 보일 때마다 호출되어 해당 위치의 위젯을 생성하며
              // index에 해당하는 메시지 객체를 buildMessage 함수에 전달하여 말풍선 위젯을 생성하는 흐름으로
              // 즉, chatbotService 객체에서 채팅 내역을 저장하는 messages 필드에 저장되어 있는
              // 마지막 채팅을 말풍선으로 그리는 부분
              itemBuilder: (context, index) {
                if (index == projectChatbotService.messages.length) {
                  // 마지막 인덱스이고, 챗봇이 입력 중이면 TypingIndicator 반환
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TypingIndicator(),
                    ),
                  );
                }
                return buildMessage(projectChatbotService.messages[index]);
              },
            ),
          ),

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
                            style: TextStyle(color: Color(0xFF0e0f10)),
                            decoration: const InputDecoration(
                              hintText: '여기에 메시지를 입력...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.mic_none,
                            color: Color(0xFF0E0F10),
                          ),
                          onPressed: () async {
                            final initResult = await recordService.initialize();

                            // ✅ 1. context.mounted 체크 추가 (안정성)
                            if (!context.mounted) return;

                            String? resultText;

                            if (initResult == true) {
                              resultText = await showModalBottomSheet<String>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder:
                                    (context) => const RecordingBottomSheet(),
                              );

                              // ✅ 2. resultText 할당 로직을 if 블록 안으로 이동 (충돌 방지)
                              if (resultText != null) {
                                // _controller.text = resultText;

                                projectChatbotService.sendMessage(
                                  resultText,
                                  "운동",
                                  authService.currentUser!.userId,
                                );

                                // 메시지 전송 후, 약간의 딜레이동안 채팅 내역을 갱신하고 스크롤 함수 실행.
                                Future.delayed(
                                  const Duration(milliseconds: 50),
                                  _scrollToBottom,
                                );
                              }
                            } else {
                              print("[System log] 마이크 권한이 거부되었거나 초기화에 실패했습니다.");
                              // (선택사항) 사용자에게 권한이 필요하다는 스낵바 메시지를 보여줄 수 있습니다.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('음성 녹음을 사용하려면 마이크 권한이 필요합니다.'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 전송 버튼
                GestureDetector(
                  onTap: () {
                    if (_controller.text.isEmpty) return; // 빈 메시지 전송 방지

                    projectChatbotService.sendMessage(
                      _controller.text,
                      "운동",
                      authService.currentUser!.userId,
                    );

                    _controller.clear();

                    // 메시지 전송 후, 약간의 딜레이동안 채팅 내역을 갱신하고 스크롤 함수 실행.
                    Future.delayed(
                      const Duration(milliseconds: 50),
                      _scrollToBottom,
                    );
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary, // 초록색 배경
                    ),
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.surface,
                    ),
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
            '프로젝트봇 1.0',
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
