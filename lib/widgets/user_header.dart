import 'package:flutter/material.dart';
import 'package:Guidini/constants/colors.dart';
import 'package:Guidini/screens/loggedin/profile_settings_screen.dart';

enum HeaderTheme { light, dark }

class UserHeader extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final HeaderTheme theme;

  const UserHeader({
    Key? key,
    required this.userData,
    this.theme = HeaderTheme.dark,
  }) : super(key: key);

  String _getInitials(String firstName, String lastName) {
    String firstInitial =
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = theme == HeaderTheme.dark;
    final Color textColor = isDark ? Colors.white : AppColors.primary800;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;
    final Color avatarBgColor = isDark ? Colors.white : AppColors.primary050;
    final Color avatarTextColor =
        isDark ? AppColors.primary800 : AppColors.primary800;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: avatarBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userData != null
                      ? _getInitials(userData!['firstName'] ?? '',
                          userData!['lastName'] ?? '')
                      : 'U',
                  style: TextStyle(
                    color: avatarTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToProfile(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userData != null
                        ? 'Hi, ${userData!['firstName']}'
                        : 'Hi, User',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Visit your profile',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: textColor,
                    size: 24,
                  ),
                ),
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
