import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tirbushona_loyalty_app/core/state/user_state.dart';
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
      curve: Curves.easeInOutCubic,
    );

    // Combine Fade and subtle Slide transition for premium feel
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0.0), // Very elegant, subtle slide from the right edge
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}

/// Global Smooth Route Builder - Forces ultra-smooth transitions on all navigations
/// Perfect for tab switches, deep links, and all screen transitions
Route createSmoothRoute(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionDuration: const Duration(milliseconds: 350), // Perfect duration for perceived performance
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Ultra-smooth ease curve that softens the beginning and end of the transition
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0.0), // Very elegant, subtle slide from the right edge
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize global user state from SharedPreferences
  await UserState().initialize();
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
        // Ensure smooth animations throughout the app
        splashFactory: InkRipple.splashFactory,
      ),
      home: const LoadingScreen(),
    );
  }
}