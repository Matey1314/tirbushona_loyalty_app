import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';

/// Custom Page Transitions Builder for smooth, premium fade and slide animations
class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  const CustomPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Smooth ease-out curve for elegant transition
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.fastOutSlowIn,
    );

    // Combine Fade and subtle Slide transition for premium feel
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0.0), // Very subtle slide from the right
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}

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
        // Custom page transitions theme for smooth, premium animations across all platforms
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionsBuilder(),
            TargetPlatform.iOS: CustomPageTransitionsBuilder(),
          },
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}