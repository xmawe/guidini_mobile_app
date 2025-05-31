import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userLocation;
  final double rating;
  final String? profilePicture;
  final bool isOnline;

  const ChatHeader({
    Key? key,
    required this.userName,
    required this.userLocation,
    required this.rating,
    this.profilePicture,
    this.isOnline = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(72);

  // Get user initials from name
  String _getInitials() {
    if (userName.isEmpty) return '?';
    
    final nameParts = userName.split(' ');
    if (nameParts.length > 1) {
      // Get first letter of first and last name
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else {
      // Just get first letter if only one name
      return userName[0].toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.gray050,
            backgroundImage: profilePicture != null ? NetworkImage(profilePicture!) : null,
            child: profilePicture == null
                ? Stack(
                    children: [
                      Center(
                        child: Text(
                          _getInitials(),
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                    ],
                  )
                : isOnline
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      userLocation,
                      style: const TextStyle(
                        color: AppColors.primary800,
                        fontSize: 13,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.primary800,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        color: AppColors.primary800,
                        fontSize: 13,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      toolbarHeight: 72,
    );
  }
}