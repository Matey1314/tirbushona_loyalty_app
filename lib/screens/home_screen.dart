import 'package:flutter/material.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCardFlipped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Header Section
                  const Text(
                    'Здравей, Матей !',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ще трупаш или приспадаш днес?',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Store Card Banner - 3D Flip Animation with No Scaling Jump
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCardFlipped = !_isCardFlipped;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 25),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: _isCardFlipped ? 3.14159 : 0,
                        ),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          final isBack = value > 1.5707; // pi/2
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateY(value),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Front Card - Sets the size of the stack
                                _buildCardFront(),
                                // Back Card - Positioned.fill ensures exact size match
                                if (isBack)
                                  Positioned.fill(
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..rotateY(3.14159),
                                      child: _buildCardBack(),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Balance Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientBlue,
                          AppColors.gradientRed,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Натрупана сума',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.savings_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '100,36 €',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.25),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // History Section Title
                  const Text(
                    'История на покупките',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Scrollable Transaction List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  _buildTransactionCard(
                    date: '10.02.2026г.',
                    totalAmount: '1119.21 €',
                    pointsText: 'Натрупано : 55.96 €',
                    isAccumulated: true,
                  ),
                  _buildTransactionCard(
                    date: '10.02.2026г.',
                    totalAmount: '94.50 €',
                    pointsText: 'Приспаднато : 15.56 €',
                    isAccumulated: false,
                  ),
                  _buildTransactionCard(
                    date: '09.02.2026г.',
                    totalAmount: '245.75 €',
                    pointsText: 'Натрупано : 12.28 €',
                    isAccumulated: true,
                  ),
                  _buildTransactionCard(
                    date: '07.02.2026г.',
                    totalAmount: '45.20 €',
                    pointsText: 'Натрупано : 2.26 €',
                    isAccumulated: true,
                  ),
                  _buildTransactionCard(
                    date: '05.02.2026г.',
                    totalAmount: '210.00 €',
                    pointsText: 'Приспаднато : 40.00 €',
                    isAccumulated: false,
                  ),
                  _buildTransactionCard(
                    date: '04.02.2026г.',
                    totalAmount: '12.50 €',
                    pointsText: 'Натрупано : 0.63 €',
                    isAccumulated: true,
                  ),
                  _buildTransactionCard(
                    date: '01.02.2026г.',
                    totalAmount: '320.45 €',
                    pointsText: 'Натрупано : 16.02 €',
                    isAccumulated: true,
                  ),
                  _buildTransactionCard(
                    date: '28.01.2026г.',
                    totalAmount: '55.00 €',
                    pointsText: 'Приспаднато : 10.00 €',
                    isAccumulated: false,
                  ),
                  _buildTransactionCard(
                    date: '25.01.2026г.',
                    totalAmount: '89.99 €',
                    pointsText: 'Натрупано : 4.50 €',
                    isAccumulated: true,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      // Pixel Perfect Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.savings_outlined, 'Начало'),
              _buildNavItem(1, Icons.credit_card, 'Карти'),
              _buildNavItem(2, Icons.trending_up, 'История'),
              _buildNavItem(3, Icons.person_outline, 'Профил'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.gradientBlue, AppColors.gradientRed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : const Color(0xFFF8FAFC),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.gradientBlue.withOpacity(0.3)
                      : Colors.black.withOpacity(0.03),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      key: const ValueKey('front'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/banner.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      key: const ValueKey('back'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Barcode Placeholder - Clean and Centered
              Container(
                height: 80,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Simple striped pattern
                    Row(
                      children: List.generate(
                        40,
                        (index) => Expanded(
                          child: Container(
                            color: index % 2 == 0 ? Colors.black : Colors.white,
                            height: 80,
                          ),
                        ),
                      ),
                    ),
                    // "SCAN BARCODE" text overlay
                    const Center(
                      child: Text(
                        'SCAN BARCODE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String date,
    required String totalAmount,
    required String pointsText,
    required bool isAccumulated,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.savings_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Дата', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Сума: $totalAmount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(
                pointsText,
                style: TextStyle(
                  color: isAccumulated ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}