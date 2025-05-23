import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class DaySeparator extends StatelessWidget {
  final String day;

  const DaySeparator({
    Key? key,
    required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.gray200,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              day,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 12,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.gray200,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
