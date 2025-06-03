import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/chat_list/chat_list_view.dart';
import '../models/chat_room.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
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
  final AuthService _authService = ServiceProvider().getAuthService();
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<ChatRoom> _searchResults = [];
  bool _isSearchLoading = false;
  bool _hasSearchError = false;
  String _searchErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
    _updateUserOnlineStatus();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Update user's online status
  Future<void> _updateUserOnlineStatus() async {
    try {
      await _authService.updateLastActivity();
      print('User online status updated');
    } catch (e) {
      print('Error updating user online status: $e');
    }
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
  
  Future<void> _searchConversations(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
      _hasSearchError = false;
    });
    
    try {
      final result = await _chatService.searchConversations(query);
      
      if (result['success'] == true) {
        List<ChatRoom> searchResults = [];
        
        // Extract conversations from the response
        final data = result['data'];
        if (data is Map<String, dynamic> && data.containsKey('conversations')) {
          final conversations = data['conversations'];
          if (conversations is List) {
            for (var room in conversations) {
              try {
                final chatRoom = ChatRoom.fromJson(room);
                searchResults.add(chatRoom);
              } catch (e) {
                print('Error parsing search result: $e');
              }
            }
          }
        }
        
        setState(() {
          _searchResults = searchResults;
          _isSearchLoading = false;
        });
      } else {
        setState(() {
          _hasSearchError = true;
          _searchErrorMessage = result['message'] ?? 'Failed to get search results';
          _isSearchLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasSearchError = true;
        _searchErrorMessage = e.toString();
        _isSearchLoading = false;
      });
    }
  }
  
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
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

  // For testing/debugging search functionality
  void _testSearchWithMockData() {
    final mockResponse = {
      "conversations": [
        {
          "id": 2,
          "other_user": {
            "id": 1,
            "name": "Ahmed El Yassifi",
            "profile_picture": "profiles/ahmed.jpg",
            "last_activity_at": "2025-05-31T07:08:49.000000Z",
            "is_online": false
          },
          "last_message": {
            "content": "Hi, any new??",
            "created_at": "2025-05-31T21:38:18.000000Z",
            "is_from_me": true
          },
          "unread_count": 0
        }
      ],
      "total": 1
    };
    
    List<ChatRoom> searchResults = [];
    
    if (mockResponse.containsKey('conversations')) {
      final conversations = mockResponse['conversations'];
      if (conversations is List) {
        for (var room in conversations) {
          try {
            final chatRoom = ChatRoom.fromJson(room);
            searchResults.add(chatRoom);
          } catch (e) {
            print('Error parsing mock search result: $e');
          }
        }
      }
    }
    
    setState(() {
      _isSearching = true;
      _isSearchLoading = false;
      _hasSearchError = false;
      _searchResults = searchResults;
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
            AppHeader(
              title: 'Chats',
              userName: 'Mohamed Jahid',
              subtitle: 'Ready for a tour?',
            ),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  suffixIcon: _isSearching 
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppColors.gray500),
                        onPressed: _clearSearch,
                      )
                    : IconButton(
                        icon: const Icon(Icons.search, color: AppColors.primary800),
                        onPressed: () {
                          if (_searchController.text.trim().isNotEmpty) {
                            _searchConversations(_searchController.text);
                          }
                        },
                      ),
                  filled: true,
                  fillColor: AppColors.gray100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  // Debounce search for better UX
                  if (value.trim().isEmpty) {
                    _clearSearch();
                  } else {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (value == _searchController.text && value.trim().isNotEmpty) {
                        _searchConversations(value);
                      }
                    });
                  }
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _searchConversations(value);
                  }
                },
                        ),
                      ),
            
            // Chat List
                      Expanded(
                child: _isSearching 
                    ? _isSearchLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _hasSearchError
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
                            const Text(
                                      'Error searching',
                              style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                              ),
                            ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _searchErrorMessage,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.gray600,
                              ),
                            ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Make a raw API call to debug
                                        _chatService.getRawApiResponse('/chat/search?query=${_searchController.text}')
                                          .then((response) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Debug Info'),
                                                content: SingleChildScrollView(
                                                  child: Text(
                                                    'Raw Response:\n${response['data'] ?? 'No data'}\n\nStatus: ${response['success'] ? 'Success' : 'Failed'}',
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Close'),
                      ),
                    ],
                  ),
                                            );
                                          });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.gray600,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('View API Response'),
                                    ),
                                  ],
                                ),
                              )
                            : _searchResults.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                                          Icons.search_off,
                                          size: 48,
                          color: AppColors.gray400,
                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No results found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No conversations match "${_searchController.text}"',
                                          style: const TextStyle(
                                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                                  )
                                : ChatListView(
                                    chatRooms: _searchResults,
                                    onChatSelected: (chat) {
                                      Navigator.pushNamed(
                                        context,
                                        '/chat',
                                        arguments: chat,
                                      ).then((_) {
                                        if (_isSearching) {
                                          _searchConversations(_searchController.text);
                                        } else {
                                          _loadChatRooms();
                                        }
                                      });
                                    },
                                  )
                    : _isLoading
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
                                        const SizedBox(height: 24),
                                        // For development/testing only
                                        ElevatedButton(
                                          onPressed: _testSearchWithMockData,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary800,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Test Search (Debug)'),
                                        ),
                                        const SizedBox(height: 16),
                                        // Test button for Guide Profile
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/guide_profile',
                                              arguments: 1, // Guide ID
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary800,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('View Guide Profile (Test)'),
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