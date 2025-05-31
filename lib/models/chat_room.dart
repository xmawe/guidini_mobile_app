import 'package:flutter/foundation.dart';

class ChatRoom {
  final dynamic id;
  final dynamic userId;
  final String userName;
  final String lastMessage;
  final DateTime lastActivity;
  final ChatRoomStatus status;
  final int unreadCount;
  final bool isVerified;
  final String? profilePicture;
  final String? location;
  final double? rating;
  final bool isOnline;
  final bool isLastMessageFromMe;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.lastActivity,
    required this.status,
    required this.unreadCount,
    required this.isVerified,
    this.profilePicture,
    this.location,
    this.rating,
    this.isOnline = false,
    this.isLastMessageFromMe = false,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    // Extract other_user data
    final otherUser = json['other_user'] as Map<String, dynamic>?;
    
    // Extract last_message data
    final lastMessageData = json['last_message'] as Map<String, dynamic>?;
    
    return ChatRoom(
      id: json['id'],
      userId: otherUser?['id'] ?? 0,
      userName: otherUser?['name']?.toString() ?? 'Unknown User',
      lastMessage: lastMessageData?['content']?.toString() ?? 'No messages yet',
      lastActivity: _parseDateTime(lastMessageData?['created_at'] ?? otherUser?['last_activity_at']),
      status: ChatRoomStatus.active, // Default to active
      unreadCount: json['unread_count'] is int ? json['unread_count'] : 0,
      isVerified: false, // This field is not in the provided JSON
      profilePicture: otherUser?['profile_picture']?.toString(),
      isOnline: otherUser?['is_online'] == true,
      isLastMessageFromMe: lastMessageData?['is_from_me'] == true,
    );
  }

  int get idAsInt {
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }
  
  int get userIdAsInt {
    if (userId is int) return userId;
    if (userId is String) return int.tryParse(userId) ?? 0;
    return 0;
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        print('Error parsing date: $e');
        return DateTime.now();
      }
    } else if (dateTime is int) {
      // Assume timestamp in seconds or milliseconds
      return dateTime > 100000000000 
          ? DateTime.fromMillisecondsSinceEpoch(dateTime) 
          : DateTime.fromMillisecondsSinceEpoch(dateTime * 1000);
    }
    
    return DateTime.now();
  }

  static ChatRoomStatus _parseStatus(dynamic status) {
    if (status == null) return ChatRoomStatus.active;
    
    if (status is String) {
      return ChatRoomStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
        orElse: () => ChatRoomStatus.active,
      );
    } else if (status is int) {
      switch (status) {
        case 0:
          return ChatRoomStatus.inactive;
        case 1:
          return ChatRoomStatus.active;
        case 2:
          return ChatRoomStatus.closed;
        default:
          return ChatRoomStatus.active;
      }
    }
    
    return ChatRoomStatus.active;
  }
  
  static int _parseIntValue(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
  
  static double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'last_message': lastMessage,
      'last_activity': lastActivity.toIso8601String(),
      'status': status.toString().split('.').last,
      'unread_count': unreadCount,
      'user_name': userName,
      'is_verified': isVerified,
      'profile_picture': profilePicture,
      'location': location,
      'rating': rating,
      'is_online': isOnline,
      'is_last_message_from_me': isLastMessageFromMe,
    };
  }
}

enum ChatRoomStatus {
  active,
  inactive,
  closed
}