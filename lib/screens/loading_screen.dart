import 'package:flutter/material.dart';
import 'package:tirbushona_loyalty_app/main.dart';
import 'login_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // Navigate to LoginScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          createSmoothRoute(const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tirbushona Logo
            Image.asset(
              'assets/images/logo.png',
              width: 250,
            ),
            const SizedBox(height: 60),
            // Bouncing Dots Indicator
            BouncingDotsIndicator(
              controller: _animationController,
            ),
          ],
        ),
      ),
    );
  }
}

class BouncingDotsIndicator extends StatelessWidget {
  final AnimationController controller;

  const BouncingDotsIndicator({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BouncingDot(
              animationValue: controller.value,
              dotIndex: 0,
            ),
            const SizedBox(width: 12),
            _BouncingDot(
              animationValue: controller.value,
              dotIndex: 1,
            ),
            const SizedBox(width: 12),
            _BouncingDot(
              animationValue: controller.value,
              dotIndex: 2,
            ),
          ],
        );
      },
    );
  }
}

class _BouncingDot extends StatelessWidget {
  final double animationValue;
  final int dotIndex;

  const _BouncingDot({
    required this.animationValue,
    required this.dotIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate staggered delay for each dot
    // dotIndex 0: starts at 0
    // dotIndex 1: starts at 0.33
    // dotIndex 2: starts at 0.66
    final normalizedValue =
        (animationValue + (dotIndex * 0.33)) % 1.0;

    // Create a bounce effect using a sine wave
    // The dot will bounce up and down
    final bounceOffset = -20 * (1 - (2 * (normalizedValue - 0.5).abs()).clamp(0.0, 1.0));

    return Transform.translate(
      offset: Offset(0, bounceOffset),
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFFDC2626),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
