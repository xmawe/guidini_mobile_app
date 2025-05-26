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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.gray200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              day,
              style: const TextStyle(
                color: AppColors.gray500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.gray200,
            ),
          ),
        ],
      ),
    );
  }
}
