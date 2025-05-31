import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/message.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;

  const ChatMessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using a unique key based on message ID and read status to force rebuild when read status changes
    return Padding(
      key: ValueKey('message_${message.id}_${message.isRead}'),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(
                message.isMe ? 'You' : message.senderName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.formattedTime,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: message.isMe ? AppColors.primary800 : AppColors.gray100,
              borderRadius: BorderRadius.only(
                topLeft: message.isMe ? const Radius.circular(8) : Radius.zero,
                topRight: message.isMe ? Radius.zero : const Radius.circular(8),
                bottomLeft: const Radius.circular(8),
                bottomRight: const Radius.circular(8),
              ),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: message.isMe ? Colors.white : AppColors.gray900,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ),
          // Show read status for user's messages
          if (message.isMe)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: message.isRead ? AppColors.primary800 : AppColors.gray400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    message.isRead ? 'Read' : 'Sent',
                    style: TextStyle(
                      fontSize: 12,
                      color: message.isRead ? AppColors.primary800 : AppColors.gray400,
                      fontWeight: message.isRead ? FontWeight.bold : FontWeight.normal,
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