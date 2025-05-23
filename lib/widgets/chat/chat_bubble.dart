import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
                Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  message.isMe ? 'You' : message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.senderText,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: message.isMe
                      ? AppColors.messageBubbleMe
                      : AppColors.messageBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: message.isMe 
                        ? const Radius.circular(6)
                        : Radius.zero,
                    topRight: message.isMe 
                        ? Radius.zero 
                        : const Radius.circular(6),
                    bottomLeft: const Radius.circular(6),
                    bottomRight: const Radius.circular(6),
                  ),
                ),
                child: Text(
                  message.text,
                  style: message.isMe
                      ? userMessageTextStyle
                      : chatMessageTextStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  message.time,
                  style: timestampTextStyle.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}