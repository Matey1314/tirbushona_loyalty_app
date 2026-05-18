import 'package:flutter/material.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';
import 'package:tirbushona_loyalty_app/services/cards_service.dart';
import 'package:tirbushona_loyalty_app/main.dart';
import 'add_card_screen.dart';
import 'card_display_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  // Using CardsService for static state management
  // _myCards is managed by CardsService.myCards

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Title
            const Text(
              'Моите карти',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Conditional: Show empty state or cards list
            if (CardsService.isEmpty())
              _buildEmptyState(context)
            else
              _buildCardsList(context),
          ],
        ),
      ),
    );
  }

  /// Build empty state UI
  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 343,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9CA3AF), width: 1),
              // You can keep the existing BoxShadow here if it was present
            ),
            // This padding is the absolute barrier preventing cropping
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Image.asset(
                'assets/images/brands_cloud.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Bottom Help Text
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main message
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Нямате добавени карти',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Instruction text
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Натиснете бутона по-долу или добавете карта от главното меню.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Add Card Button (Narrowed and Centered)
              GestureDetector(
                onTap: () {
                  Navigator.push(context, createSmoothRoute(const AddCardScreen()));
                },
                child: Container(
                  width: 180,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFF2563EB)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF2E30AD),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        offset: const Offset(0, 15),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Добави Карта',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build cards list UI with Grid View
  Widget _buildCardsList(BuildContext context) {
    final cards = CardsService.getCards();
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: cards.length + 1, // +1 for the "Add Card" button
        itemBuilder: (context, index) {
          // Last item is the "Нова карта" button
          if (index == cards.length) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, createSmoothRoute(const AddCardScreen()));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'нова карта',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Regular card tiles with Figma specs
          final card = cards[index];
          return InkWell(
            onTap: () {
              Navigator.push(context, createSmoothRoute(CardDisplayScreen(card: card)));
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                // Logo Container with exact Figma dimensions
                child: Container(
                  width: 120,
                  height: 75,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      card['logo']!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.credit_card, size: 32, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
