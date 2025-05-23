import 'package:Guidini/widgets/chat/day_separator.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/chat/chat_bubble.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class ChatScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.messageText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: chatMessageTextStyle.copyWith(
                    color: AppColors.profileName,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      userLocation,
                      style: chatMessageTextStyle.copyWith(
                        color: AppColors.profileLocation,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(
                      rating.toString(),
                      style: chatMessageTextStyle.copyWith(
                        color: AppColors.profileRating,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: chatMessageTextStyle.copyWith(
                      color: AppColors.inputText,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: inputHintTextStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.sendButton,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.messageTextMe),
                    onPressed: () {},
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