import 'package:Guidini/constants/colors.dart';
import 'package:Guidini/screens/home_screen.dart';
import 'package:Guidini/screens/loggedin/bookings_screen.dart';
import 'package:Guidini/screens/loggedin/conversations_screen.dart';
import 'package:Guidini/screens/public/search_screen.dart';
import 'package:Guidini/widgets/user_header.dart';
import 'package:Guidini/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _userData;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getUserData();
      setState(() {
        _userData = userData;
        _isLoadingUserData = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const SearchScreen();
      case 2:
        return const BookingsScreen();
      case 3:
        return const ConversationsScreen();
      default:
        return const HomeScreen();
    }
  }

  HeaderTheme _getCurrentHeaderTheme() {
    // Home screen uses dark theme, others use light
    return _selectedIndex == 0 ? HeaderTheme.dark : HeaderTheme.light;
  }

  SystemUiOverlayStyle _getCurrentSystemOverlayStyle() {
    // Home screen uses light overlay (for dark background), others use dark
    return _selectedIndex == 0
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }

  // Color _getCurrentBackgroundColor() {
  //   // Home screen has gradient, others have white background
  //   return _selectedIndex == 0 ? AppColors.primary800 : Colors.white;
  // }

  Widget _buildScreenContent() {
    if (_selectedIndex == 0) {
      // Home screen with gradient background
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary800,
              AppColors.primary800.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!_isLoadingUserData)
                UserHeader(
                  userData: _userData,
                  theme: _getCurrentHeaderTheme(),
                ),
              Expanded(child: _getCurrentScreen()),
            ],
          ),
        ),
      );
    } else {
      // Other screens with white background
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              if (!_isLoadingUserData)
                UserHeader(
                  userData: _userData,
                  theme: _getCurrentHeaderTheme(),
                ),
              Expanded(child: _getCurrentScreen()),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary800),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _getCurrentSystemOverlayStyle(),
      child: Scaffold(
        body: _buildScreenContent(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: SvgPicture.asset(
                      'lib/assets/icons/home_inactive.svg',
                      width: 24,
                      height: 24,
                    ),
                    activeIcon: SvgPicture.asset(
                      'lib/assets/icons/home_active.svg',
                      width: 24,
                      height: 24,
                    ),
                    label: 'Home',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: SvgPicture.asset(
                      'lib/assets/icons/search_refraction_inactive.svg',
                      width: 24,
                      height: 24,
                    ),
                    activeIcon: SvgPicture.asset(
                      'lib/assets/icons/search_refraction_active.svg',
                      width: 24,
                      height: 24,
                    ),
                    label: 'Search',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: SvgPicture.asset(
                      'lib/assets/icons/ticket_02_inactive.svg',
                      width: 24,
                      height: 24,
                    ),
                    activeIcon: SvgPicture.asset(
                      'lib/assets/icons/ticket_02_active.svg',
                      width: 24,
                      height: 24,
                    ),
                    label: 'Bookings',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: SvgPicture.asset(
                      'lib/assets/icons/message_text_circle_02_inactive.svg',
                      width: 24,
                      height: 24,
                    ),
                    activeIcon: SvgPicture.asset(
                      'lib/assets/icons/message_text_circle_02_active.svg',
                      width: 24,
                      height: 24,
                    ),
                    label: 'Conversations',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required Widget icon,
    required Widget activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: isSelected ? activeIcon : icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary800 : AppColors.gray500,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
