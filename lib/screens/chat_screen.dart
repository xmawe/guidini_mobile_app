import 'package:Guidini/widgets/chat/day_separator.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/chat/chat_bubble.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/chat_header.dart'; // Add this import
import '../constants/colors.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userLocation;
  final double rating;

  const ChatScreen({
    Key? key,
    required this.userName,
    required this.userLocation,
    required this.rating,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ChatHeader(
        userName: widget.userName,
        userLocation: widget.userLocation,
        rating: widget.rating,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Column(
                  children: [
                    if (message.day != null) 
                      DaySeparator(day: message.day!),
                    ChatBubble(message: message),
                  ],
                );
              },
            ),
          ),
          ChatInput(
            controller: _messageController,
            onSend: () {
              if (_messageController.text.isNotEmpty) {
                // Handle sending message
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}