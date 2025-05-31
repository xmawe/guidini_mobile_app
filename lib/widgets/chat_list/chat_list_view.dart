import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/chat_room.dart';
import '../../utils/string_utils.dart';

class ChatListView extends StatelessWidget {
  final List<ChatRoom> chatRooms;
  final Function(ChatRoom) onChatSelected;

  const ChatListView({
    Key? key,
    required this.chatRooms,
    required this.onChatSelected,
  }) : super(key: key);

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: chatRooms.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.gray100,
      ),
      itemBuilder: (context, index) {
        final chat = chatRooms[index];
        final initials = StringUtils.getInitials(chat.userName);
        
        return InkWell(
          onTap: () => onChatSelected(chat),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: Colors.pink[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Online indicator
                    if (chat.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Chat info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.userName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat.isVerified) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: AppColors.primary800,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (chat.isLastMessageFromMe)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.reply,
                                size: 12,
                                color: AppColors.gray500,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              chat.lastMessage,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                color: chat.unreadCount > 0 ? AppColors.gray900 : AppColors.gray500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Timestamp and unread count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTimestamp(chat.lastActivity),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                        color: chat.unreadCount > 0 ? AppColors.primary800 : AppColors.gray500,
                      ),
                    ),
                    if (chat.unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary800,
                          borderRadius: BorderRadius.circular(10),
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
        );
      },
    );
  }
}
// Mock data
final mockChatRooms = [
  ChatRoom(
    id: '1',
    userId: 'guide_1',
    userName: 'Ahmed El Yassifi',
    lastMessage: "Thanks for reaching out. I'll get back to you as soon as I can...",
    lastActivity: DateTime.now().subtract(const Duration(minutes: 2)),
    status: ChatRoomStatus.active,
    unreadCount: 1,
    isVerified: true,
    location: 'Marrakech, Morocco',
    rating: 4.5,
  ),
  ChatRoom(
    id: '2',
    userId: 'guide_2',
    userName: 'Mohamed Ibrahimi',
    lastMessage: "Okay!",
    lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
    status: ChatRoomStatus.active,
    unreadCount: 2,
    isVerified: true,
    location: 'Fes, Morocco',
    rating: 4.8,
  ),
  ChatRoom(
    id: '3',
    userId: 'guide_3',
    userName: 'Ayoub Moussaoui',
    lastMessage: "Thanks for reaching out.",
    lastActivity: DateTime.now().subtract(const Duration(days: 1)),
    status: ChatRoomStatus.active,
    unreadCount: 0,
    isVerified: false,
    location: 'Casablanca, Morocco',
    rating: 4.2,
  ),
  // Add more mock chat rooms as needed...
];
