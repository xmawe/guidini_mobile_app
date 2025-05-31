import 'package:Guidini/models/chat_screen_arguments.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/chat_room.dart';

class ChatListItem extends StatelessWidget {
  final ChatRoom chat;
  final VoidCallback onTap;

  const ChatListItem({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  // Get user initials from name
  String _getInitials() {
    final name = chat.userName;
    if (name.isEmpty) return '?';
    
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      // Get first letter of first and last name
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else {
      // Just get first letter if only one name
      return name[0].toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: chat.profilePicture != null
                      ? AssetImage(chat.profilePicture!)
                      : null,
                  child: chat.profilePicture == null
                      ? Text(
                          _getInitials(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (chat.isVerified)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatLastActivity(chat.lastActivity),
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.unreadCount > 0
                              ? AppColors.primary
                              : AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: chat.unreadCount > 0
                                ? AppColors.gray900
                                : AppColors.gray600,
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastActivity(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}