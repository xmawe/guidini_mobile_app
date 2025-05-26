import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userLocation;
  final double rating;

  const ChatHeader({
    Key? key,
    required this.userName,
    required this.userLocation,
    required this.rating,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(72);

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
            child: Stack(
              children: [
                Center(
                  child: Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.gray900,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
            ),
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