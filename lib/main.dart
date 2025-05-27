import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Guidini/screens/onboard_screen.dart';
import 'package:Guidini/screens/auth/login_screen.dart';
import 'package:Guidini/screens/auth/register_screen.dart';
import 'package:Guidini/layouts/main_navigation_screen.dart'; // Add this import
import 'package:Guidini/services/auth_service.dart';
import "package:Guidini/constants/colors.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guidini',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary800),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/onboard': (context) => const OnboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigationScreen(),
        '/main': (context) => const MainNavigationScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isFirstTime = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if it's first time opening the app
      final isFirstTime = prefs.getBool('first_time') ?? true;

      // Check if user is logged in
      final token = prefs.getString('auth_token');
      final isLoggedIn = token != null && token.isNotEmpty;

      // If user is logged in, verify token is still valid
      if (isLoggedIn) {
        final isValid = await AuthService.verifyToken(token);
        if (!isValid) {
          // Token is invalid, clear it
          await prefs.remove('auth_token');
          await prefs.remove('user_data');
        }

        setState(() {
          _isFirstTime = isFirstTime;
          _isLoggedIn = isValid;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isFirstTime = isFirstTime;
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking auth state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isFirstTime) {
      return const OnboardScreen();
    } else if (_isLoggedIn) {
      return const MainNavigationScreen(); // Changed this line
    } else {
      return const OnboardScreen();
    }
  }
}
