import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../widgets/chat/chat_message_bubble.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/chat_header.dart';
import '../widgets/chat/day_separator.dart';

class ChatScreen extends StatelessWidget {
  final ChatRoom chat;

  const ChatScreen({
    Key? key,
    required this.chat,
  }) : super(key: key);

  List<Widget> _buildMessageList() {
    final List<Widget> messageWidgets = [];
    String? currentDate;

    // Iterate through messages in reverse order for proper date grouping
    for (int i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      final messageDate = message.formattedDate;

      // Add date separator if date changes
      if (messageDate != currentDate) {
        if (currentDate != null) {
          messageWidgets.add(DaySeparator(day: messageDate));
        }
        currentDate = messageDate;
      }

      messageWidgets.add(ChatMessageBubble(message: message));
    }

    // Add the first date separator at the end (will appear at the top when reversed)
    if (messages.isNotEmpty) {
      messageWidgets.add(DaySeparator(day: messages.last.formattedDate));
    }

    return messageWidgets.reversed.toList(); // Reverse back to chronological order
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatHeader(
        userName: chat.userName,
        userLocation: chat.location ?? 'Unknown location',
        rating: chat.rating ?? 4.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              children: _buildMessageList(),
            ),
          ),
          const ChatInput(),
        ],
      ),
    );
  }
}