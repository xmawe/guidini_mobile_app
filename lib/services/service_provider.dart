import 'chat_service.dart';
import 'guide_service.dart';
import 'auth_service.dart';

class ServiceProvider {
  static final ServiceProvider _instance = ServiceProvider._internal();
  late final ChatService chatService;
  late final GuideService guideService;
  late final AuthService authService;
  
  // Factory constructor
  factory ServiceProvider() {
    return _instance;
  }
  
  // Private constructor
  ServiceProvider._internal() {
    chatService = ChatService();
    guideService = GuideService();
    authService = AuthService();
  }
  
  // Get the chat service instance
  ChatService getChatService() {
    return chatService;
  }
  
  // Get the guide service instance
  GuideService getGuideService() {
    return guideService;
  }
  
  // Get the auth service instance
  AuthService getAuthService() {
    return authService;
  }
} 