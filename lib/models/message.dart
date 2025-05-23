class Message {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final String senderName;  // For display purposes
  final String? day;       // For UI grouping

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.readAt,
    this.isRead = false,
    required this.senderName,
    this.day,
  });

  // Convert timestamp to readable time
  String get formattedTime {
    return "${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}${createdAt.hour >= 12 ? 'pm' : 'am'}";
  }

  // Check if message is from current user
  bool get isMe => senderId == 'current_user_id'; // Replace with actual user ID check
}

// Sample data
final List<Message> messages = [
  Message(
    id: '1',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "Welcome to Marrakech! 🌟 I'll be your guide for today's medina tour.",
    createdAt: DateTime(2024, 5, 24, 9, 0),
    senderName: "Hassan",
    day: "Today",
  ),
  Message(
    id: '2',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "Hi Hassan! Excited to explore. Where do we start?",
    createdAt: DateTime(2024, 5, 24, 9, 1),
    senderName: "You",
  ),
  Message(
    id: '3',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "We'll begin at Jemaa el-Fnaa square, then explore the souks. Are you at your hotel now?",
    createdAt: DateTime(2024, 5, 24, 9, 2),
    senderName: "Hassan",
  ),
  Message(
    id: '4',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "Yes, I'm at Riad Mamounia. How long will it take to reach there?",
    createdAt: DateTime(2024, 5, 24, 9, 3),
    senderName: "You",
  ),
  Message(
    id: '5',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "Perfect! I'll meet you in 15 minutes. Look for me wearing a blue guide badge 🏷️",
    createdAt: DateTime(2024, 5, 24, 9, 4),
    senderName: "Hassan",
  ),
  Message(
    id: '6',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "This spice market smells amazing! 🌶️ What's this red spice called?",
    createdAt: DateTime(2024, 5, 24, 10, 30),
    senderName: "You",
  ),
  Message(
    id: '7',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "That's Moroccan paprika! Perfect for tagine dishes. Would you like to try some authentic spice blends?",
    createdAt: DateTime(2024, 5, 24, 10, 31),
    senderName: "Hassan",
  ),
  Message(
    id: '8',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "Definitely! Can we also visit that carpet shop we passed earlier?",
    createdAt: DateTime(2024, 5, 24, 10, 33),
    senderName: "You",
  ),
  Message(
    id: '9',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "Of course! After lunch at the rooftop restaurant I recommended. The view of Koutoubia Mosque is stunning from there 🕌",
    createdAt: DateTime(2024, 5, 24, 10, 34),
    senderName: "Hassan",
  ),
  Message(
    id: '10',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "Quick break by the fountain. Do you need water or rest? It's getting warm ☀️",
    createdAt: DateTime(2024, 5, 24, 11, 45),
    senderName: "Hassan",
  ),
  Message(
    id: '11',
    chatRoomId: 'room_1',
    senderId: 'current_user_id',
    content: "A short rest would be great! This mint tea is refreshing 🍵",
    createdAt: DateTime(2024, 5, 24, 11, 46),
    senderName: "You",
  ),
  Message(
    id: '12',
    chatRoomId: 'room_1',
    senderId: 'guide_1',
    content: "That's our famous Moroccan hospitality! Ready to explore the artisan quarter next?",
    createdAt: DateTime(2024, 5, 24, 11, 48),
    senderName: "Hassan",
  ),
];