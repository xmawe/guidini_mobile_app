import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class ChatService {
  // Use 10.0.2.2 for Android emulator to connect to host machine's localhost
  // Use 127.0.0.1 for iOS simulator
  static String get _baseUrl {
    
      return 'http://127.0.0.1:8000/api';
    
  }
  
  final Dio _dio = Dio();

  ChatService() {
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    _dio.options.baseUrl = _baseUrl;
    print('Using API base URL: ${_dio.options.baseUrl}');
    
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Get token from SharedPreferences and set it if exists
    final token = await _getStoredToken();
    if (token != null) {
      setToken(token);
      print('Token loaded from storage: $token');
    } else {
      print('No token found in storage');
    }
  }

  // Token management
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('Token set in headers: Bearer $token');
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('chat_token');
  }

  // Cache management
  Future<void> _cacheData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final jsonString = json.encode(data);
      await prefs.setString(key, jsonString);
      print('Cached data for key: $key');
    } catch (e) {
      print('Error caching data for key $key: $e');
    }
  }

  Future<dynamic> _getCachedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return null;
    
    try {
      final decoded = json.decode(data);
      print('Retrieved cached data for key: $key');
      return decoded;
    } catch (e) {
      print('Error decoding cached data for key $key: $e');
      return null;
    }
  }

  // Get all chat rooms with caching
  Future<Map<String, dynamic>> getChatRooms() async {
    try {
      // Always fetch from API and then update cache
      // This ensures we get the latest unread counts
      print('Fetching chat rooms from API');
      final response = await _dio.get('/chat/rooms');
      print('API Response for chat rooms: ${response.data}');
      
      // Extract the data from the response
      dynamic responseData = response.data;
      
      // If response is a string (JSON string), try to parse it
      if (responseData is String) {
        try {
          responseData = json.decode(responseData);
          print('Parsed JSON string response: $responseData');
        } catch (e) {
          print('Error parsing JSON string: $e');
        }
      }
      
      // Handle different response structures
      dynamic chatRoomsData;
      
      if (responseData is Map<String, dynamic>) {
        // Common Laravel API response format: { data: [...] }
        if (responseData.containsKey('data') && responseData['data'] != null) {
          chatRoomsData = responseData['data'];
        } 
        // Another common format: { chats: [...] } or { rooms: [...] }
        else if ((responseData.containsKey('chats') && responseData['chats'] != null) ||
                 (responseData.containsKey('rooms') && responseData['rooms'] != null)) {
          chatRoomsData = responseData['chats'] ?? responseData['rooms'];
        }
        // If we can't find a list, use the whole response
        else {
          chatRoomsData = responseData;
        }
      } else if (responseData is List) {
        // If it's already a list, use it directly
        chatRoomsData = responseData;
      } else {
        print('Unexpected response format: ${responseData.runtimeType}');
        return {
          'success': false,
          'message': 'Unexpected response format',
        };
      }
      
      print('Extracted chat rooms data: $chatRoomsData');
      await _cacheData('chat_rooms', chatRoomsData);
      
      return {
        'success': true,
        'data': chatRoomsData,
        'fromCache': false,
      };
    } catch (e) {
      print('Error fetching chat rooms: $e');
      
      // Try to get cached data if API call fails
      final cachedData = await _getCachedData('chat_rooms');
      if (cachedData != null) {
        print('Using cached chat rooms data due to API error');
        return {
          'success': true,
          'data': cachedData,
          'fromCache': true,
        };
      }
      
      return {
        'success': false,
        'message': _handleError(e).toString(),
      };
    }
  }

  // Direct API call for debugging purposes
  Future<Map<String, dynamic>> getRawApiResponse(String endpoint) async {
    try {
      print('Making direct API call to: $endpoint');
      final response = await _dio.get(endpoint);
      print('Raw API response: ${response.data}');
      
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      print('Error making direct API call: $e');
      return {
        'success': false,
        'message': _handleError(e).toString(),
      };
    }
  }
  

  // Get messages with pagination
  Future<Map<String, dynamic>> getMessages(dynamic roomId, {int? beforeId, int limit = 50}) async {
    try {
      // Convert roomId to int if it's a string
      final int roomIdInt = roomId is int ? roomId : 
                           (roomId is String ? int.tryParse(roomId) ?? 0 : 0);
      
      print('Fetching messages for room $roomIdInt, before: $beforeId, limit: $limit');
      
      // Build query parameters, only include beforeId if it's not null
      final Map<String, dynamic> queryParams = {'limit': limit};
      if (beforeId != null) {
        queryParams['before_id'] = beforeId;
      }
      
      final response = await _dio.get(
        '/chat/rooms/$roomIdInt/messages',
        queryParameters: queryParams,
      );
      
      print('API Response for messages: ${response.data}');
      
      // Extract the data from the response
      final responseData = response.data;
      
      // Handle different response structures
      dynamic messagesData;
      bool hasMore = false;
      
      if (responseData is Map<String, dynamic>) {
        // Check for the new API format with 'messages' and 'has_more' fields
        if (responseData.containsKey('messages')) {
          messagesData = responseData['messages'];
          hasMore = responseData['has_more'] == true;
        }
        // Fallback to old format - look for data field or use the whole response
        else {
          messagesData = responseData['data'] ?? responseData;
        }
      } else if (responseData is List) {
        // If it's already a list, use it directly
        messagesData = responseData;
      } else {
        print('Unexpected response format: ${responseData.runtimeType}');
        return {
          'success': false,
          'message': 'Unexpected response format',
        };
      }
      
      // Automatically mark messages as read after retrieving them
      // This ensures read status is updated immediately
      if (beforeId == null) {  // Only for initial load, not for pagination
        try {
          markAsRead(roomIdInt);
        } catch (e) {
          print('Error auto-marking messages as read: $e');
        }
      }
      
      return {
        'success': true,
        'data': messagesData,
        'has_more': hasMore,
      };
    } catch (e) {
      print('Error fetching messages: $e');
      return {
        'success': false,
        'message': _handleError(e).toString(),
      };
    }
  }

  // Search messages in a chat room
  Future<dynamic> searchMessages(int roomId, String query) async {
    try {
      final response = await _dio.get(
        '/chat/rooms/$roomId/search',
        queryParameters: {'query': query},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Create or get existing chat room
  Future<dynamic> createOrGetChatRoom(int userId) async {
    try {
      final response = await _dio.post(
        '/chat/rooms',
        data: {'user_id': userId},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Send message with optimistic update
  Future<Map<String, dynamic>> sendMessage(dynamic roomId, String content) async {
    try {
      // Convert roomId to int if it's a string
      final int roomIdInt = roomId is int ? roomId : 
                           (roomId is String ? int.tryParse(roomId) ?? 0 : 0);
      
      print('Sending message to room $roomIdInt: $content');
      
      // Create temporary message for optimistic update
      final tempMessage = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'content': content,
        'sending': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Update local cache immediately
      final cachedMessages = await _getCachedData('room_${roomIdInt}_messages') ?? [];
      cachedMessages.insert(0, tempMessage);
      await _cacheData('room_${roomIdInt}_messages', cachedMessages);

      // Send actual request
      final response = await _dio.post(
        '/chat/rooms/$roomIdInt/messages',
        data: {'content': content},
      );

      print('API Response for send message: ${response.data}');
      
      // Extract the data from the response
      final responseData = response.data;
      
      // Handle different response structures
      dynamic messageData;
      if (responseData is Map<String, dynamic>) {
        // If the response is a map, look for data field or use the whole response
        messageData = responseData['data'] ?? responseData;
      } else {
        // Use the response directly
        messageData = responseData;
      }

      // Update cache with real message
      cachedMessages[0] = messageData;
      await _cacheData('room_${roomIdInt}_messages', cachedMessages);

      return {
        'success': true,
        'data': messageData,
        'tempId': tempMessage['id'],
      };
    } catch (e) {
      print('Error sending message: $e');
      return {
        'success': false,
        'message': _handleError(e).toString(),
      };
    }
  }

  // Mark messages as read
  Future<Map<String, dynamic>> markAsRead(dynamic roomId) async {
    try {
      // Convert roomId to int if it's a string
      final int roomIdInt = roomId is int ? roomId : 
                           (roomId is String ? int.tryParse(roomId) ?? 0 : 0);
      
      if (roomIdInt <= 0) {
        print('Invalid room ID for marking messages as read: $roomId');
        return {
          'success': false,
          'message': 'Invalid room ID',
        };
      }
      
      print('Marking messages as read for room $roomIdInt');
      
      try {
        final response = await _dio.post('/chat/rooms/$roomIdInt/read');
        
        // Update local cache of messages
        try {
          final cachedMessages = await _getCachedData('room_${roomIdInt}_messages');
          if (cachedMessages != null && cachedMessages is List) {
            final updatedMessages = cachedMessages.map((msg) {
              if (msg is Map<String, dynamic> && msg['is_from_me'] != true) {
                msg['is_read'] = true;
                if (msg['read_at'] == null) {
                  msg['read_at'] = DateTime.now().toIso8601String();
                }
              }
              return msg;
            }).toList();
            
            await _cacheData('room_${roomIdInt}_messages', updatedMessages);
          }
          
          // Update the unread count in the cached chat rooms list
          final cachedRooms = await _getCachedData('chat_rooms');
          if (cachedRooms != null && cachedRooms is List) {
            int updatedRoomCount = 0;
            
            final updatedRooms = cachedRooms.map((room) {
              if (room is Map<String, dynamic>) {
                final roomIdFromCache = room['id'];
                final roomIdFromCacheInt = roomIdFromCache is int ? roomIdFromCache : 
                                (roomIdFromCache is String ? int.tryParse(roomIdFromCache) ?? 0 : 0);
                
                if (roomIdFromCacheInt == roomIdInt) {
                  if (room['unread_count'] > 0) {
                    updatedRoomCount++;
                    room['unread_count'] = 0;
                  }
                }
              }
              return room;
            }).toList();
            
            if (updatedRoomCount > 0) {
              await _cacheData('chat_rooms', updatedRooms);
              print('Updated unread count for room $roomIdInt in cache');
            }
          }
        } catch (e) {
          print('Error updating cached data: $e');
        }
        
        return {
          'success': true,
          'data': response.data,
        };
      } catch (e) {
        print('Error in API call to mark messages as read: $e');
        
        // Even if the API call fails, we'll still update the UI
        // This ensures a better user experience
        return {
          'success': true,
          'data': {'message': 'Messages marked as read (local only)'},
          'localOnly': true,
        };
      }
    } catch (e) {
      print('Error marking messages as read: $e');
      return {
        'success': false,
        'message': _handleError(e).toString(),
      };
    }
  }

  // Update user's last activity
  Future<void> updateLastActivity() async {
    try {
      await _dio.post('/chat/activity');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get chat room details
  Future<dynamic> getChatRoomDetails(dynamic roomId) async {
    try {
      // Convert roomId to int if it's a string
      final int roomIdInt = roomId is int ? roomId : 
                           (roomId is String ? int.tryParse(roomId) ?? 0 : 0);
      
      final response = await _dio.get('/chat/rooms/$roomIdInt');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Search conversations
  Future<dynamic> searchConversations(String query) async {
    try {
      final response = await _dio.get(
        '/chat/search',
        queryParameters: {'query': query},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Clear chat cache
  Future<void> clearChatCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('room_') || key == 'chat_rooms');
    for (final key in keys) {
      await prefs.remove(key);
    }
    print('Chat cache cleared');
  }

  // Enhanced error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      print('DioException: ${error.message}');
      print('Status code: ${error.response?.statusCode}');
      print('Response data: ${error.response?.data}');
      
      if (error.response?.statusCode == 401) {
        // Handle unauthorized access
        clearChatCache(); // Clear cached data on auth error
        return Exception('Authentication required');
      }
      if (error.response?.data != null) {
        final message = error.response?.data['message'] ?? 'An error occurred';
        return Exception(message);
      }
      return Exception(error.message ?? 'Network error occurred');
    }
    return Exception('An unexpected error occurred: $error');
  }
}