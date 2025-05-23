import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

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
      child: Center(
        child: Text(
          day,
          style: timestampTextStyle.copyWith(
            color: AppColors.secondaryText,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
