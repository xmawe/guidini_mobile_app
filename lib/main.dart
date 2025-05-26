import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'models/chat_room.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';

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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const ChatListScreen(),
          );
        } else if (settings.name == '/chat') {
          final chat = settings.arguments as ChatRoom;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          );
        }
        return null;
      },
    );
  }
}
