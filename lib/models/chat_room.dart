import 'package:flutter/foundation.dart';

class ChatRoom {
  final String id;
  final String userId;
  final String lastMessage;
  final DateTime lastActivity;
  final ChatRoomStatus status;
  final int unreadCount;
  final String userName;
  final bool isVerified;
  final String? profilePicture;
  final String? location;
  final double? rating;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.lastMessage,
    required this.lastActivity,
    required this.status,
    required this.unreadCount,
    required this.userName,
    required this.isVerified,
    this.profilePicture,
    this.location,
    this.rating,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lastMessage: json['last_message'] as String,
      lastActivity: DateTime.parse(json['last_activity'] as String),
      status: ChatRoomStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ChatRoomStatus.active,
      ),
      unreadCount: json['unread_count'] as int? ?? 0,
      userName: json['user_name'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      profilePicture: json['profile_picture'] as String?,
      location: json['location'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
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
    };
  }
}

enum ChatRoomStatus {
  active,
  inactive,
  closed
}