import 'package:Guidini/screens/loggedin/change_password_screen.dart';
import 'package:Guidini/screens/loggedin/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:Guidini/services/auth_service.dart';
import 'package:Guidini/constants/colors.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _notificationsEnabled = true;

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
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getInitials(String firstName, String lastName) {
    String firstInitial =
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  Future<void> _logout() async {
    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content:
              const Text('Are you sure you want to log out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.gray600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary800,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile Settings'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Fallback to home screen if no previous route
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar with initials
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary800.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _userData != null
                            ? _getInitials(_userData!['firstName'] ?? '',
                                _userData!['lastName'] ?? '')
                            : 'U',
                        style: const TextStyle(
                          color: AppColors.primary800,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // User name
                  if (_userData != null) ...[
                    Text(
                      '${_userData!['firstName']} ${_userData!['lastName']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _userData!['email'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // General Section
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: Text(
                      'General',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  _buildSettingsItem(
                    icon: Icons.person_outline,
                    iconColor: AppColors.primary800,
                    title: 'Edit Profile',
                    subtitle: 'Change profile picture, number, E-mail',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      // If profile was updated, refresh the profile settings screen
                      if (result == true) {
                        _loadUserData();
                      }
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.lock_outline,
                    iconColor: AppColors.primary800,
                    title: 'Change Password',
                    subtitle: 'Update and strengthen account security',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.description_outlined,
                    iconColor: AppColors.primary800,
                    title: 'Terms of Use',
                    subtitle: 'Protect your account now',
                    onTap: () {
                      // TODO: Navigate to terms of use screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Terms of Use coming soon!')),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.credit_card_outlined,
                    iconColor: AppColors.primary800,
                    title: 'Add Card',
                    subtitle: 'Securely add payment method',
                    onTap: () {
                      // TODO: Navigate to add card screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add Card coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Preferences Section
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  _buildSettingsItem(
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.primary800,
                    title: 'Notification',
                    subtitle: 'Customize your notification preferences',
                    onTap: () {
                      // TODO: Navigate to notification settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Notification settings coming soon!')),
                      );
                    },
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      activeColor: AppColors.primary800,
                    ),
                  ),
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    iconColor: AppColors.primary800,
                    title: 'FAQ',
                    subtitle: 'Frequently asked questions',
                    onTap: () {
                      // TODO: Navigate to FAQ screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('FAQ coming soon!')),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.logout,
                    iconColor: Colors.red,
                    title: 'Log Out',
                    subtitle: 'Securely log out of Account',
                    onTap: _showLogoutDialog,
                    titleColor: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
