import 'package:flutter/material.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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

                // Store Card Banner
                AspectRatio(
                  aspectRatio: 2.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/banner.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Balance Card (Натрупана сума)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.gradientBlue, // #2563EB
                        AppColors.gradientRed, // #DC2626
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top row: "Натрупана сума" + Piggy Bank Icon
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
                          Icon(
                            Icons.savings_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Bottom row: "100,36 €" with text shadow
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
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // История на покупките (History) Section
                const Text(
                  'История на покупките',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction Cards
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
                  date: '08.02.2026г.',
                  totalAmount: '67.99 €',
                  pointsText: 'Натрупано : 3.40 €',
                  isAccumulated: true,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),

      // Custom Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Начало (Home)
              _buildNavItem(
                index: 0,
                icon: Icons.savings_outlined,
                label: 'Начало',
                isSelected: _selectedIndex == 0,
              ),
              // Карти (Cards)
              _buildNavItem(
                index: 1,
                icon: Icons.credit_card,
                label: 'Карти',
                isSelected: _selectedIndex == 1,
              ),
              // История (History)
              _buildNavItem(
                index: 2,
                icon: Icons.trending_up,
                label: 'История',
                isSelected: _selectedIndex == 2,
              ),
              // Настройки (Settings)
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline,
                label: 'Настройки',
                isSelected: _selectedIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container (Active: Gradient, Inactive: Light Grey)
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        AppColors.gradientBlue, // #2563EB
                        AppColors.gradientRed, // #DC2626
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : const Color(0xFFF8FAFC),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.gradientBlue.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, isSelected ? 4 : 2),
                  blurRadius: isSelected ? 8 : 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                size: 28,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Text Label (Grey for both active and inactive)
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Red Circular Icon Container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDC2626),
            ),
            child: const Center(
              child: Icon(
                Icons.savings_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Middle: Date Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Дата',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right: Amount & Points Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Сума : $totalAmount',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pointsText,
                style: TextStyle(
                  color: isAccumulated ? const Color(0xFF22C55E) : const Color(0xFFDC2626),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
