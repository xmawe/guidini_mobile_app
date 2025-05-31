// lib/layouts/main_navigation_screen.dart
import 'package:guidini/constants/colors.dart';
import 'package:guidini/screens/home_screen.dart';
import 'package:guidini/screens/loggedin/bookings_screen.dart';
import 'package:guidini/screens/loggedin/conversations_screen.dart';
import 'package:guidini/screens/public/search_screen.dart';
// Import guide screens
import 'package:guidini/screens/guide/guide_dashboard_screen.dart';
import 'package:guidini/screens/guide/my_tours_screen.dart';
import 'package:guidini/screens/guide/guide_bookings_screen.dart';
import 'package:guidini/widgets/user_header.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:guidini/providers/user_role_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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

      // Update user role provider with latest user data
      if (mounted) {
        Provider.of<UserRoleProvider>(context, listen: false)
            .updateUserData(userData ?? {});
      }
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
    final userRoleProvider = Provider.of<UserRoleProvider>(context);

    if (userRoleProvider.isTourist) {
      // Tourist screens
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
    } else {
      // Guide screens
      switch (_selectedIndex) {
        case 0:
          return const GuideDashboardScreen();
        case 1:
          return const MyToursScreen();
        case 2:
          return const GuideBookingsScreen();
        case 3:
          return const ConversationsScreen();
        default:
          return const GuideDashboardScreen();
      }
    }
  }

  HeaderTheme _getCurrentHeaderTheme() {
    // Home screen uses dark theme, others use light
    final userRoleProvider = Provider.of<UserRoleProvider>(context);

    return _selectedIndex == 0 && userRoleProvider.isTourist
        ? HeaderTheme.dark
        : HeaderTheme.light;
  }

  SystemUiOverlayStyle _getCurrentSystemOverlayStyle() {
    final userRoleProvider = Provider.of<UserRoleProvider>(context);
    // Home screen uses light overlay (for dark background), others use dark
    return _selectedIndex == 0 && userRoleProvider.isTourist
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }

  Widget _buildScreenContent() {
    final userRoleProvider = Provider.of<UserRoleProvider>(context);
    if (_selectedIndex == 0 && userRoleProvider.isTourist) {
      // Home screen with gradient background
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary800,
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

    return Consumer<UserRoleProvider>(
      builder: (context, userRoleProvider, child) {
        final navigationItems = userRoleProvider.getNavigationItems();

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: navigationItems.map((item) {
                      return _buildNavItem(
                        icon: SvgPicture.asset(
                          item.icon,
                          width: 24,
                          height: 24,
                        ),
                        activeIcon: SvgPicture.asset(
                          item.activeIcon,
                          width: 24,
                          height: 24,
                        ),
                        label: item.label,
                        index: item.index,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
