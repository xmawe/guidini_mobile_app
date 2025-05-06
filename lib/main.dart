import 'package:flutter/material.dart';
import 'screens/onboard_screen.dart'; // Import the OnboardScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove the debug badge
      home: const OnboardScreen(), // Set OnboardScreen as the home widget
    );
  }
}
