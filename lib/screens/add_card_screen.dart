import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirbushona_loyalty_app/main.dart';
import 'add_card_details_screen.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _supabase = Supabase.instance.client;
  
  // Празни списъци, които ще напълним от базата данни
  List<Map<String, dynamic>> _brands = [];
  List<Map<String, dynamic>> filteredBrands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBrandsFromDatabase();
  }

  // Изтегляне на шаблоните (магазините) от Supabase
  Future<void> _fetchBrandsFromDatabase() async {
    try {
      final data = await _supabase.from('card_templates').select().order('name');
      if (mounted) {
        setState(() {
          _brands = List<Map<String, dynamic>>.from(data);
          filteredBrands = _brands; // Първоначално показваме всички
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Грешка при зареждане на магазините: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Логиката на търсачката остава същата, просто работи с динамичните данни
  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBrands = _brands;
      } else {
        filteredBrands = _brands
            .where((brand) =>
                (brand['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Добави карта',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterBrands,
                decoration: InputDecoration(
                  hintText: 'Търси...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Brand List
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : filteredBrands.isEmpty
                  ? Center(
                      child: Text(
                        'Няма резултати за "${_searchController.text}"',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: filteredBrands.length,
                      itemBuilder: (context, index) {
                        final brand = filteredBrands[index];
                        final logoUrl = brand['logo_url'] ?? 'assets/images/banner.png'; // Дефолтна картинка
                        
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              createSmoothRoute(
                                AddCardDetailsScreen(brand: brand),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  offset: const Offset(0, 4),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Logo - Exact Figma Dimensions 75x45
                                  Container(
                                    width: 75,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(4.0),
                                    child: Center(
                                      child: _buildImage(logoUrl), // Ползваме помощната функция за логото
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  // Brand Name - bold black text
                                  Expanded(
                                    child: Text(
                                      brand['name'] ?? 'Неизвестен',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Tap indicator
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF9CA3AF),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Text
                  const Text(
                    'Не намираш своята карта ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Button
                  GestureDetector(
                    onTap: () {
                      debugPrint('Add card from here...');
                      // Navigate to add custom card form
                    },
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDC2626), Color(0xFF2563EB)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.20),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'ДОБАВИ Я ОТ ТУК',
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
            ),
          ],
        ),
      ),
    );
  }

  // Помощна функция за зареждане на логото (онлайн или локално)
  Widget _buildImage(String source) {
    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 24),
      );
    } else {
      return Image.asset(
        source,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 24),
      );
    }
  }
}

// Прост екран за детайли при добавяне на карта (замества липсващия файл/клас)
class AddCardDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> brand;

  const AddCardDetailsScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(brand['name'] ?? 'Детайли на картата', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/images/banner.png', height: 80, fit: BoxFit.contain)),
            const SizedBox(height: 20),
            Text(brand['name'] ?? 'Неизвестен', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(brand['description'] ?? ''),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Добави карта'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}