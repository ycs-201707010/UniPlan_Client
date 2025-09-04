// ** 2025-08-09 챗봇 화면 made by 김민석 **

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:all_new_uniplan/models/schedule_model.dart';
import 'package:all_new_uniplan/models/chat_message_model_2.dart';
import 'package:intl/intl.dart';
import 'package:all_new_uniplan/services/schedule_service.dart';
import '../screens/scheduleSheets.dart';
import 'dart:convert';
import 'package:all_new_uniplan/services/chatbot_service_2.dart';
import 'package:all_new_uniplan/services/auth_service.dart';

class ChatMecaPage extends StatefulWidget {
  const ChatMecaPage({super.key});

  @override
  State<ChatMecaPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatMecaPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Schedule 객체를 _ChatPageState의 멤버 변수로 선언
  // '일정 추가 요청' 시 여기에 값을 할당하고, '아니오' 클릭 시 null로 만들 수 있도록 합니다.

  // 메시지 버블의 내용을 렌더링하는 함수 수정
  Widget buildMessage(ChatMessage chatMessage) {
    final isUser = chatMessage.speaker;

    // 메시지 내용들을 담을 List
    List<Widget> children = [];

    // 텍스트가 있으면 Text 위젯 추가
    if (chatMessage.message.isNotEmpty) {
      children.add(
        Text(
          chatMessage.message,
          style: TextStyle(
            color:
                chatMessage.speaker == ChatMessageType.user
                    ? Colors.black
                    : Colors.black,
          ),
        ),
      );
    }

    // showButtons이 true인 경우에만 버튼 위젯 추가
    if (chatMessage.showButtons) {
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
                final chatbotService = context.read<ChatbotService>();
                final authService = context.read<AuthService>();

                if (chatbotService.cureentMessage.showButtons) {
                  setState(() {
                    chatbotService.confirmScheduleAddition(
                      authService.currentUser!.userId,
                    );
                  });
                } else {}
              },
              child: const Text('예'),
            ),
            const SizedBox(width: 16), // 버튼 사이 간격
            OutlinedButton(
              onPressed: () {
                setState(() {
                  final chatbotService = context.read<ChatbotService>();

                  chatbotService.cancelScheduleAddition();
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
      alignment:
          chatMessage.speaker == ChatMessageType.user
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment:
              chatMessage.speaker == ChatMessageType.user
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chatMessage.speaker != ChatMessageType.user)
              CircleAvatar(radius: 16, backgroundColor: Colors.black),
            if (chatMessage.speaker != ChatMessageType.user) SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color:
                      chatMessage.speaker != ChatMessageType.user
                          ? Colors.blue[100]
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: content, // 텍스트와 버튼이 포함된 Column을 여기에 넣습니다.
              ),
            ),
            if (chatMessage.speaker != ChatMessageType.user) SizedBox(width: 8),
            if (chatMessage.speaker != ChatMessageType.user)
              CircleAvatar(radius: 16, backgroundColor: Colors.black),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatbotService = context.read<ChatbotService>();
    final authService = context.read<AuthService>();
    return Scaffold(
      appBar: AppBar(title: Text('ChatBot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatbotService.messages.length,
              itemBuilder: (context, index) {
                return buildMessage(chatbotService.messages[index]);
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "메시지를 입력하세요",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      () => chatbotService.sendMessage(
                        _controller.text,
                        authService.currentUser!.userId,
                      ),
                  child: Text("보내기"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
