import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TirbushonaApp());
}

class TirbushonaApp extends StatelessWidget {
  const TirbushonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tirbushona Loyalty App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Задаваме леко сивия фон за цялото приложение
        scaffoldBackgroundColor: const Color(0xFFE9EDF4), 
      ),
      home: const LoginScreen(),
    );
  }
}