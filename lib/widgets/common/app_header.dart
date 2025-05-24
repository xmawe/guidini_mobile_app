import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'notification_bell.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showNotification;

  const AppHeader({
    Key? key,
    required this.title,
    this.showNotification = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary050,
            child: Text(
              'MJ', // Should come from user data
              style: TextStyle(
                color: AppColors.primary500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ready for a tour ?', // Could be made dynamic
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (showNotification)
            NotificationBell(
              notificationCount: 1, // Could be made dynamic
              onTap: () {
                // Handle notification tap
              },
            ),
        ],
      ),
    );
  }
}