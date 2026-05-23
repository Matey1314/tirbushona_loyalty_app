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

  @override
  Widget build(BuildContext context) {
    final userId = _supabase.auth.currentUser?.id;

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
            
            // Списъкът се обновява в реално време и е сортиран по най-използвани
            Expanded(
              child: userId == null
                  ? const Center(child: Text('Моля, влез в профила си.'))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _supabase
                          .from('wallet_cards')
                          .stream(primaryKey: ['id'])
                          .eq('user_id', userId)
                          .order('usage_count', ascending: false),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final cards = snapshot.data!;

                        if (cards.isEmpty) {
                          return _buildEmptyState(context);
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: cards.length + 1,
                          itemBuilder: (context, index) {
                            if (index == cards.length) {
                              return _buildAddCardButton(context);
                            }

                            final card = cards[index];
                            return FutureBuilder<Map<String, dynamic>?>(
                              future: _supabase.from('card_templates').select().eq('id', card['template_id']).maybeSingle(),
                              builder: (context, snapshot) {
                                final logoUrl = snapshot.data?['logo_url'] ?? '';
                                return InkWell(
                                  onTap: () => Navigator.push(context, createSmoothRoute(CardDisplayScreen(card: card))),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                                    ),
                                    child: Center(
                                      child: logoUrl.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Image.network(logoUrl, fit: BoxFit.contain),
                                            )
                                          : Text(card['store_name'] ?? 'Карта'),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: cards.length + 1, // +1 за бутона
      itemBuilder: (context, index) {
        if (index == cards.length) {
          return _buildAddCardButton(context);
        }

        final card = cards[index];
        return FutureBuilder<Map<String, dynamic>?>(
          future: _supabase.from('card_templates').select().eq('id', card['template_id']).maybeSingle(),
          builder: (context, snapshot) {
            final logoUrl = snapshot.data?['logo_url'] ?? '';

            return InkWell(
              onTap: () => Navigator.push(context, createSmoothRoute(CardDisplayScreen(card: card))),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                ),
                child: Center(
                  child: logoUrl.isNotEmpty
                      ? Padding(padding: const EdgeInsets.all(12), child: Image.network(logoUrl, fit: BoxFit.contain))
                      : Text(card['store_name'] ?? 'Карта'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddCardButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, createSmoothRoute(const AddCardScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              offset: const Offset(0, 6),
              blurRadius: 14,
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
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
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
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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