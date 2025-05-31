import 'chat_service.dart';

class ServiceProvider {
  static final ServiceProvider _instance = ServiceProvider._internal();
  late final ChatService chatService;
  
  // Factory constructor
  factory ServiceProvider() {
    return _instance;
  }
  
  // Private constructor
  ServiceProvider._internal() {
    chatService = ChatService();
  }
  
  // Get the chat service instance
  ChatService getChatService() {
    return chatService;
  }
} 