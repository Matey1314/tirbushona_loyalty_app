import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      appBar: AppBar(
        title: const Text('Tirbushona'),
        centerTitle: true,
        backgroundColor: const Color(0xFFE9EDF4),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Добре дошли в Tirbushona!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
