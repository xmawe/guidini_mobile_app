import 'package:Guidini/constants/colors.dart';
import 'package:flutter/material.dart';
import 'app_header.dart';
import 'custom_app_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showNotification;
  final int currentIndex;

  const AppScaffold({
    Key? key,
    required this.child,
    required this.title,
    this.showNotification = true,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: title,
              showNotification: showNotification,
              userName: 'Mohamed Jahid', // Default user name
            ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: CustomAppBar(
        currentIndex: currentIndex,
        userName: 'Mohamed Jahid', // Default user name
        subtitle: 'Ready for a tour?', // Default subtitle
      ),
    );
  }
}