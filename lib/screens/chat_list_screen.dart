import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/chat_list/chat_list_view.dart';
import '../models/chat_room.dart';
import '../services/chat_service.dart';
import '../services/service_provider.dart';
import '../services/token_service.dart';
import '../widgets/common/app_header.dart';

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
        // If no token is set, navigate to token setup screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/token_setup');
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final result = await _chatService.getChatRooms();
      
      if (result['success'] == true) {
        final data = result['data'];
        
        final List<ChatRoom> rooms = [];
        
        // Process data based on its type
        if (data is List) {
          for (var room in data) {
            try {
              final chatRoom = ChatRoom.fromJson(room);
              rooms.add(chatRoom);
            } catch (e) {
              print('Error parsing chat room: $e');
            }
          }
        } else if (data is Map) {
          // Try to find a list in the map
          for (var key in data.keys) {
            final value = data[key];
            if (value is List) {
              for (var room in value) {
                try {
                  final chatRoom = ChatRoom.fromJson(room);
                  rooms.add(chatRoom);
                } catch (e) {
                  print('Error parsing chat room from key "$key": $e');
                }
              }
              break;
            }
          }
        }
        
        setState(() {
          _chatRooms = rooms;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = result['message'] ?? 'Failed to load chat rooms';
          _isLoading = false;
        });
      }
    } catch (e) {
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
            AppHeader(
              title: 'Chats',
              userName: 'Mohamed Jahid',
              subtitle: 'Ready for a tour?',
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
                                    Navigator.pushNamed(
                                      context,
                                      '/chat',
                                      arguments: chat,
                                    ).then((_) {
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