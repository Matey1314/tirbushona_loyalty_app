import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';

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
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}