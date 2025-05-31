import 'package:flutter/material.dart';
import 'package:guidini/providers/user_role_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guidini/screens/onboard_screen.dart';
import 'package:guidini/screens/auth/login_screen.dart';
import 'package:guidini/screens/auth/register_screen.dart';
import 'package:guidini/layouts/main_navigation_screen.dart';
import 'package:guidini/services/auth_service.dart';
import "package:guidini/constants/colors.dart";
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
      ],
      child: MaterialApp(
        title: 'guidini',
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
      ),
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
        } else {
          // Initialize user role provider with user data
          final userData = await AuthService.getUserData();
          if (mounted) {
            await Provider.of<UserRoleProvider>(context, listen: false)
                .initialize(userData);
          }
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
      return const MainNavigationScreen();
    } else {
      return const OnboardScreen();
    }
  }
}
