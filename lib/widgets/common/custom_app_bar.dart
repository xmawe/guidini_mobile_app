import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'notification_bell.dart';
import '../../utils/string_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final String userName;
  final String subtitle;

  const CustomAppBar({
    Key? key,
    required this.currentIndex,
    required this.userName,
    required this.subtitle,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.getInitials(userName);
    
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.gray200.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User avatar with initials
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(26),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.pink[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            // Notification bell
            const NotificationBell(),
          ],
        ),
      ),
    );
  }
}