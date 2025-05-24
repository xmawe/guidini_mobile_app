import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/chat_room.dart';
import 'chat_list_item.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar with light gray background
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.gray050,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: AppColors.gray400,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.gray400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        // Chat list
        Expanded(
          child: ListView.separated(
            itemCount: mockChatRooms.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.gray100,
            ),
            itemBuilder: (context, index) {
              return ChatListItem(
                chat: mockChatRooms[index],
                onTap: () {
                  // Handle chat item tap
                },
              );
            },
          ),
        ),
      ],
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
    status: 'active',
    unreadCount: 1,
    isVerified: true,
  ),
  ChatRoom(
    id: '2',
    userId: 'guide_2',
    userName: 'Mohamed Ibrahimi',
    lastMessage: "Okay!",
    lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
    status: 'active',
    unreadCount: 2,
    isVerified: true,
  ),
  ChatRoom(
    id: '3',
    userId: 'guide_3',
    userName: 'Ayoub Moussaoui',
    lastMessage: "Thanks for reaching out.",
    lastActivity: DateTime.now().subtract(const Duration(days: 1)),
    status: 'active',
    unreadCount: 0,
    isVerified: false,
  ),
  // Add more mock chat rooms as needed...
];