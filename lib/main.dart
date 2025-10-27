import 'package:flutter/material.dart';
import 'login/login_page.dart';

void main() {
  runApp(const FoodTrackApp());
}

class FoodTrackApp extends StatelessWidget {
  const FoodTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Track System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const LoginPage(),
    );
  }
}