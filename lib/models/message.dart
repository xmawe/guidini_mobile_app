import 'package:flutter/foundation.dart';

class Message {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final String senderName;
  final String? senderProfilePicture;
  final bool isGuide;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.readAt,
    this.isRead = false,
    required this.senderName,
    this.senderProfilePicture,
    required this.isGuide,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      isRead: json['is_read'] as bool? ?? false,
      senderName: json['sender_name'] as String,
      senderProfilePicture: json['sender_profile_picture'] as String?,
      isGuide: json['is_guide'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'is_read': isRead,
      'sender_name': senderName,
      'sender_profile_picture': senderProfilePicture,
      'is_guide': isGuide,
    };
  }

  // Convert timestamp to readable time
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get formatted date for grouping
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format as "Thursday" or similar
      return '${createdAt.day} ${_getWeekday(createdAt.weekday)}';
    }
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  // Get full formatted date with time
  String get formattedDateTime {
    return '${_getWeekday(createdAt.weekday)} ${formattedTime}';
  }

  // Check if message is from current user (to be implemented with actual auth)
  bool get isMe => senderId == 'current_user_id'; // Replace with actual user ID check
}

// Sample data for testing
final List<Message> messages = [
  Message(
    id: '1',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "Hi! I saw your booking request for the Marrakech city tour. I'd be happy to be your guide! 🌟",
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
    senderName: "Ahmed El Yassifi",
    isGuide: true,
  ),
  Message(
    id: '2',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "Hello Ahmed! Yes, I'm planning to visit next week. I'm particularly interested in the historic sites and local cuisine.",
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 45)),
    senderName: "You",
    isGuide: false,
  ),
  Message(
    id: '3',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "Perfect! I specialize in cultural tours and know all the best local restaurants in the medina. How many days will you be staying?",
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 30)),
    senderName: "Ahmed El Yassifi",
    isGuide: true,
  ),
  Message(
    id: '4',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "I'll be there for 4 days, arriving on Monday next week.",
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
    senderName: "You",
    isGuide: false,
  ),
  Message(
    id: '5',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "Great! Here's what I suggest for your tour:\n\n1. Day 1: Medina, souks & Jemaa el-Fnaa\n2. Day 2: Historical monuments & gardens\n3. Day 3: Cooking class & food tour\n4. Day 4: Atlas Mountains day trip\n\nHow does that sound? 🌴",
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    senderName: "Ahmed El Yassifi",
    isGuide: true,
  ),
  Message(
    id: '6',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "That sounds amazing! I love the idea of the cooking class. What kind of dishes would we learn to make?",
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4, minutes: 30)),
    senderName: "You",
    isGuide: false,
  ),
  Message(
    id: '7',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "We'll learn to make traditional Moroccan dishes like tagine, couscous, and pastilla. We'll start with a visit to the spice market to get fresh ingredients! 🥘",
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
    senderName: "Ahmed El Yassifi",
    isGuide: true,
  ),
  Message(
    id: '8',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "Perfect! And for the Atlas Mountains trip, is it suitable for someone with moderate fitness level?",
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    senderName: "You",
    isGuide: false,
  ),
  Message(
    id: '9',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "Absolutely! The trek is gentle with plenty of breaks. We'll visit Berber villages, have lunch with a local family, and enjoy stunning mountain views. 🏔️",
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 45)),
    senderName: "Ahmed El Yassifi",
    isGuide: true,
  ),
  Message(
    id: '10',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "Sounds perfect! What's the best way to prepare for the trip? Any specific things I should pack?",
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    senderName: "You",
    isGuide: false,
  ),
  Message(
    id: '11',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "For the mountain trip, bring:\n- Comfortable walking shoes\n- Sun protection (hat, sunscreen)\n- Light jacket (it's cooler in the mountains)\n- Camera 📸\n- Water bottle\n\nFor the city tours, light comfortable clothing and sun protection are essential.",
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    senderName: "Ahmed El Yassifi",
    isGuide: true,
  ),
  Message(
    id: '12',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "Thanks for the detailed list! One more question - what's the best time to start each day?",
    createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
    senderName: "You",
    isGuide: false,
  ),
  Message(
    id: '13',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "I suggest starting at 9:00 AM for city tours and 8:00 AM for the Atlas Mountains trip (to avoid midday heat). We can adjust the timing based on your preference! ⏰",
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    senderName: "Ahmed El Yassifi",
    isGuide: true,
  ),
  Message(
    id: '14',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "Those times work perfectly for me. I'm really looking forward to the tour!",
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    senderName: "You",
    isGuide: false,
  ),
  Message(
    id: '15',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "Great! I'll send you the meeting point details soon. Feel free to ask any other questions you might have! 😊",
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    senderName: "Ahmed El Yassifi",
    isGuide: true,
  ),
];