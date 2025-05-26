import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/chat_list/chat_list_view.dart';
import '../models/chat_room.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _currentIndex = 3; // Conversations tab

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary050,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'MJ',
                            style: TextStyle(
                              color: AppColors.primary800,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello, Mohamed',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray900,
                              ),
                            ),
                            const Text(
                              'Ready for a tour?',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                        color: AppColors.gray900,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gray050,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.gray400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: AppColors.gray400,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              // Handle search
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Chat List
            Expanded(
              child: ChatListView(
                chatRooms: mockChatRooms,
                onChatSelected: (chat) {
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: chat,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// Mock data
final List<ChatRoom> mockChatRooms = [
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
    location: 'Chefchaouen, Morocco',
  ),
  ChatRoom(
    id: '4',
    userId: 'guide_4',
    userName: 'Hafid Elmoudden',
    lastMessage: "Thanks for reaching out.",
    lastActivity: DateTime.now().subtract(const Duration(days: 1)),
    status: ChatRoomStatus.active,
    unreadCount: 0,
    isVerified: false,
    location: 'Tangier, Morocco',
  ),
  ChatRoom(
    id: '5',
    userId: 'guide_5',
    userName: 'Mohamed Jada',
    lastMessage: "Thanks for reaching out.",
    lastActivity: DateTime.now().subtract(const Duration(days: 7)),
    status: ChatRoomStatus.inactive,
    unreadCount: 0,
    isVerified: true,
    location: 'Casablanca, Morocco',
  ),
];