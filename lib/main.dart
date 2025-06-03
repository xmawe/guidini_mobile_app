import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'models/chat_room.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/token_setup_screen.dart';
import 'screens/guide_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guidini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.gray900),
          titleTextStyle: TextStyle(
            color: AppColors.gray900,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: Colors.white,
          surface: Colors.white,
        ),
      ),
      initialRoute: '/token_setup',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const ChatListScreen(),
          );
        } else if (settings.name == '/chat_list') {
          return MaterialPageRoute(
            builder: (context) => const ChatListScreen(),
          );
        } else if (settings.name == '/chat') {
          // Handle both ChatRoom objects and Map arguments
          if (settings.arguments is ChatRoom) {
            final chat = settings.arguments as ChatRoom;
            return MaterialPageRoute(
              builder: (context) => ChatScreen(chat: chat),
            );
          } else if (settings.arguments is Map) {
            // Handle chat data from guide profile
            final args = settings.arguments as Map<dynamic, dynamic>;
            
            try {
              // Convert the dynamic Map to a Map<String, dynamic> before creating the ChatRoom
              final Map<String, dynamic> chatData = {};
              args.forEach((key, value) {
                chatData[key.toString()] = value;
              });
              
              final chatRoom = ChatRoom.fromJson(chatData);
              
              return MaterialPageRoute(
                builder: (context) => ChatScreen(chat: chatRoom),
              );
            } catch (e) {
              print('Error creating ChatRoom from Map: $e');
              // Return error screen if chat room creation fails
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Failed to open chat room'),
                        const SizedBox(height: 8),
                        Text('Error: $e', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/');
                          },
                          child: const Text('Go to Chat List'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return MaterialPageRoute(
              builder: (context) => const ChatListScreen(),
            );
          }
        } else if (settings.name == '/token_setup') {
          return MaterialPageRoute(
            builder: (context) => const TokenSetupScreen(),
          );
        } else if (settings.name == '/guide_profile') {
          final guideId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => GuideProfileScreen(guideId: guideId),
          );
        }
        return null;
      },
    );
  }
}
