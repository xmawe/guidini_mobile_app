import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'notification_bell.dart';
import '../../utils/string_utils.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showNotification;
  final String? subtitle;
  final String userName;

  const AppHeader({
    Key? key,
    required this.title,
    this.showNotification = true,
    this.subtitle = 'Ready for a tour ?',
    this.userName = 'Mohamed Jahid',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userInitials = StringUtils.getInitials(userName);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    userInitials,
                    style: TextStyle(
                      color: Colors.pink[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${userName.split(' ').first}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray500,
                        ),
                      ),
                  ],
                ),
              ),
              if (showNotification)
                NotificationBell(
                  notificationCount: 1,
                  onTap: () {
                    // Handle notification tap
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gray050,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppColors.gray400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: AppColors.gray400,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
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