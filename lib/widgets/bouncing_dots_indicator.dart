import 'package:flutter/material.dart';

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
    final normalizedValue =
        (animationValue + (dotIndex * 0.33)) % 1.0;

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
