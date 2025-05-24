class ChatRoom {
  final String id;
  final String userId;
  final String lastMessage;
  final DateTime lastActivity;
  final String status;
  final int unreadCount;
  final String userName;
  final bool isVerified;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.lastMessage,
    required this.lastActivity,
    required this.status,
    required this.unreadCount,
    required this.userName,
    required this.isVerified,
  });
}