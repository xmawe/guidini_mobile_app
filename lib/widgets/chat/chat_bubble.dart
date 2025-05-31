import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/string_utils.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.getInitials(message.senderName);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.pink[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray600,
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
                      ? AppColors.primary
                      : AppColors.gray050,
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
                  message.content,
                  style: message.isMe
                      ? userMessageTextStyle
                      : chatMessageTextStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.formattedTime,
                      style: timestampTextStyle,
                    ),
                    if (message.isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: AppColors.gray400,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}