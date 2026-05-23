import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirbushona_loyalty_app/main.dart';
import 'add_card_screen.dart';
import 'card_display_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _myCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  // Изтегляне на картите от Supabase
  Future<void> _fetchCards() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Взимаме картите на потребителя + данните за логото от каталога
      final data = await _supabase
          .from('loyalty_cards')
          .select('*, card_templates(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _myCards = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      debugPrint('Грешка при зареждане на картите: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
            const SizedBox(height: 16),
            
            // Conditional: Show loading, empty state or cards list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _myCards.isEmpty
                      ? _buildEmptyState(context)
                      : _buildCardsList(context, _myCards),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state UI (ЗАПАЗЕН НА 100% ОТ ТВОЯ КОД)
  Widget _buildEmptyState(BuildContext context) {
    return Column(
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
          ),
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Image.asset(
              'assets/images/brands_cloud.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            GestureDetector(
              onTap: () async {
                // Изчакваме да се върне от екрана за добавяне и презареждаме картите
                await Navigator.push(context, createSmoothRoute(const AddCardScreen()));
                _fetchCards();
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
    );
  }

  /// Build cards list UI with Grid View (ЗАПАЗЕН НА 100% ОТ ТВОЯ КОД)
  Widget _buildCardsList(BuildContext context, List<Map<String, dynamic>> cards) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: cards.length + 1,
      itemBuilder: (context, index) {
        // Бутонът "Нова карта" винаги е последен
        if (index == cards.length) {
          return GestureDetector(
            onTap: () async {
              await Navigator.push(context, createSmoothRoute(const AddCardScreen()));
              _fetchCards();
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
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

        // Дизайнът на самите карти
        final card = cards[index];
        final template = card['card_templates'] ?? {};
        final logoSource = template['logo_url'] ?? 'assets/images/banner.png'; // Дефолтна снимка, ако няма

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
                  child: _buildImage(logoSource),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Помощна функция за зареждане на логото
  Widget _buildImage(String source) {
    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.credit_card, size: 32, color: Colors.grey),
      );
    } else {
      return Image.asset(
        source,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.credit_card, size: 32, color: Colors.grey),
      );
    }
  }
}