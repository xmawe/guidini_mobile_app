// lib/providers/user_role_provider.dartAdd commentMore actions
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { tourist, guide }

class UserRoleProvider with ChangeNotifier {
  UserRole _currentRole = UserRole.tourist;
  bool _canSwitchToGuide = false;
  Map<String, dynamic>? _userData;
  static const String _roleKey = 'user_role';
  static const String _canSwitchKey = 'can_switch_to_guide';

  UserRole get currentRole => _currentRole;
  bool get canSwitchToGuide => _canSwitchToGuide;
  Map<String, dynamic>? get userData => _userData;
  bool get isTourist => _currentRole == UserRole.tourist;
  bool get isGuide => _currentRole == UserRole.guide;

  /// Initialize the provider with user data and saved preferences
  Future<void> initialize(Map<String, dynamic>? userData) async {
    _userData = userData;
    await _loadSavedRole();
    await _checkGuideEligibility();
    notifyListeners();
  }

  /// Load saved role from SharedPreferences
  Future<void> _loadSavedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString(_roleKey);

      if (savedRole != null) {
        _currentRole = savedRole == 'guide' ? UserRole.guide : UserRole.tourist;
      }
    } catch (e) {
      // print('Error loading saved role: $e');
    }
  }

  /// Check if user can switch to guide role based on their profile
  Future<void> _checkGuideEligibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user has completed guide registration
      // This could be based on having guide-specific data in profile
      // or a flag from your backend API
      _canSwitchToGuide = prefs.getBool(_canSwitchKey) ??
          (_userData?['isGuide'] == true) ??
          (_userData?['guideProfile'] != null);
    } catch (e) {
      // print('Error checking guide eligibility: $e');
    }
  }

  /// Switch user role
  Future<void> switchRole(UserRole newRole) async {
    if (newRole == UserRole.guide && !_canSwitchToGuide) {
      throw Exception('User is not eligible to switch to guide role');
    }

    _currentRole = newRole;
    await _saveRole();
    notifyListeners();
  }

  /// Save current role to SharedPreferences
  Future<void> _saveRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _roleKey, _currentRole == UserRole.guide ? 'guide' : 'tourist');
    } catch (e) {
      // print('Error saving role: $e');
    }
  }

  /// Enable guide role switching (call this after successful guide registration)
  Future<void> enableGuideRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_canSwitchKey, true);
      _canSwitchToGuide = true;
      notifyListeners();
    } catch (e) {
      // print('Error enabling guide role: $e');
    }
  }

  /// Update user data
  void updateUserData(Map<String, dynamic> userData) {
    _userData = userData;
    _checkGuideEligibility();
    notifyListeners();
  }

  /// Reset role state (call on logout)
  void reset() {
    _currentRole = UserRole.tourist;
    _canSwitchToGuide = false;
    _userData = null;
    notifyListeners();
  }

  /// Get role-specific navigation items
  List<NavigationItem> getNavigationItems() {
    if (_currentRole == UserRole.tourist) {
      return [
        NavigationItem(
          icon: 'lib/assets/icons/home_inactive.svg',
          activeIcon: 'lib/assets/icons/home_active.svg',
          label: 'Home',
          index: 0,
        ),
        NavigationItem(
          icon: 'lib/assets/icons/search_refraction_inactive.svg',
          activeIcon: 'lib/assets/icons/search_refraction_active.svg',
          label: 'Search',
          index: 1,
        ),
        NavigationItem(
          icon: 'lib/assets/icons/ticket_02_inactive.svg',
          activeIcon: 'lib/assets/icons/ticket_02_active.svg',
          label: 'Bookings',
          index: 2,
        ),
        NavigationItem(
          icon: 'lib/assets/icons/message_text_circle_02_inactive.svg',
          activeIcon: 'lib/assets/icons/message_text_circle_02_active.svg',
          label: 'Messages',
          index: 3,
        ),
      ];
    } else {
      // Guide navigation items
      return [
        NavigationItem(
          icon: 'lib/assets/icons/bar_chart_square_01_inactive.svg',
          activeIcon: 'lib/assets/icons/bar_chart_square_01_active.svg',
          label: 'Dashboard',
          index: 0,
        ),
        NavigationItem(
          icon: 'lib/assets/icons/compass_03_inactive.svg',
          activeIcon: 'lib/assets/icons/compass_03_active.svg',
          label: 'My Tours',
          index: 1,
        ),
        NavigationItem(
          icon: 'lib/assets/icons/ticket_02_inactive.svg',
          activeIcon: 'lib/assets/icons/ticket_02_active.svg',
          label: 'Bookings',
          index: 2,
        ),
        NavigationItem(
          icon: 'lib/assets/icons/message_text_circle_02_inactive.svg',
          activeIcon: 'lib/assets/icons/message_text_circle_02_active.svg',
          label: 'Messages',
          index: 3,
        ),
      ];
    }
  }
}

class NavigationItem {
  final String icon;
  final String activeIcon;
  final String label;
  final int index;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });
}
