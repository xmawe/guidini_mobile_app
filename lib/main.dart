import 'package:flutter/material.dart';
import 'screens/my_bookings_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookings App',
      theme: ThemeData(primarySwatch: Colors.red),
      home: MyBookingsScreen(),
    );
  }
}
