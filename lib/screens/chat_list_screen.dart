import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/chat_list/chat_list_view.dart';
import '../models/chat_room.dart';
import '../services/chat_service.dart';
import '../services/service_provider.dart';
import '../services/token_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _currentIndex = 3; // Conversations tab
  final ChatService _chatService = ServiceProvider().getChatService();
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        print('No token found, navigating to token setup screen');
        // If no token is set, navigate to token setup screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/token_setup');
        });
        return;
      }

      print('Token found, loading chat rooms');
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final result = await _chatService.getChatRooms();
      print('Chat rooms API result structure: ${result.keys.toList()}');
      
      if (result['success'] == true) {
        final data = result['data'];
        print('Chat rooms data type: ${data.runtimeType}');
        
        final List<ChatRoom> rooms = [];
        
        // Process data based on its type
        if (data is List) {
          print('Processing list data with ${data.length} items');
          for (var room in data) {
            try {
              final chatRoom = ChatRoom.fromJson(room);
              rooms.add(chatRoom);
              
              // Print unread count for debugging
              print('Chat room ${chatRoom.idAsInt} unread count: ${chatRoom.unreadCount}');
            } catch (e) {
              print('Error parsing chat room: $e');
              print('Room data: $room');
            }
          }
        } else if (data is Map) {
          print('Data is a Map with keys: ${data.keys.toList()}');
          // Try to find a list in the map
          for (var key in data.keys) {
            final value = data[key];
            if (value is List) {
              print('Found list in key "$key" with ${value.length} items');
              for (var room in value) {
                try {
                  final chatRoom = ChatRoom.fromJson(room);
                  rooms.add(chatRoom);
                  
                  // Print unread count for debugging
                  print('Chat room ${chatRoom.idAsInt} unread count: ${chatRoom.unreadCount}');
                } catch (e) {
                  print('Error parsing chat room from key "$key": $e');
                  print('Room data: $room');
                }
              }
              break;
            }
          }
        }
        
        print('Parsed ${rooms.length} chat rooms');
        setState(() {
          _chatRooms = rooms;
          _isLoading = false;
        });
      } else {
        print('API returned error: ${result['message']}');
        setState(() {
          _hasError = true;
          _errorMessage = result['message'] ?? 'Failed to load chat rooms';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Exception in _loadChatRooms: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _clearCacheAndReload() async {
    setState(() {
      _isLoading = true;
    });
    
    await _chatService.clearChatCache();
    _loadChatRooms();
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
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.pushNamed(context, '/token_setup');
                        },
                        color: AppColors.gray900,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadChatRooms,
                            tooltip: 'Refresh',
                            color: AppColors.gray900,
                            iconSize: 20,
                            padding: EdgeInsets.all(4),
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading chats',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.gray600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _loadChatRooms,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary800,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Try Again'),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: _clearCacheAndReload,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.gray600,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Clear Cache & Reload'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : _chatRooms.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.chat_bubble_outline,
                                      size: 48,
                                      color: AppColors.gray400,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No chats yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Your conversations will appear here',
                                      style: TextStyle(
                                        color: AppColors.gray600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  await _loadChatRooms();
                                },
                                color: AppColors.primary800,
                                child: ChatListView(
                                  chatRooms: _chatRooms,
                                  onChatSelected: (chat) {
                                    print('Navigating to chat room ${chat.idAsInt}');
                                    Navigator.pushNamed(
                                      context,
                                      '/chat',
                                      arguments: chat,
                                    ).then((_) {
                                      print('Returned from chat room ${chat.idAsInt}, refreshing chat list');
                                      _loadChatRooms();
                                    });
                                  },
                                ),
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