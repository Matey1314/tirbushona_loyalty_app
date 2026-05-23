import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirbushona_loyalty_app/screens/add_card_details_screen.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _brands = [];
  List<Map<String, dynamic>> filteredBrands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBrandsFromDatabase();
  }

  Future<void> _fetchBrandsFromDatabase() async {
    try {
      final data = await _supabase.from('card_templates').select().order('name');
      if (mounted) {
        setState(() {
          _brands = List<Map<String, dynamic>>.from(data);
          filteredBrands = _brands; 
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Грешка при зареждане на магазините: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
            // Хедър
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Добави карта',
                    style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Търсачка
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterBrands,
                decoration: InputDecoration(
                  hintText: 'Търси...',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Списък с магазините
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : filteredBrands.isEmpty
                  ? Center(
                      child: Text(
                        'Няма резултати за "${_searchController.text}"',
                        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: filteredBrands.length,
                      itemBuilder: (context, index) {
                        final brand = filteredBrands[index];
                        final logoUrl = brand['logo_url'] ?? 'assets/images/banner.png'; 
                        
                        return GestureDetector(
                          onTap: () {
                            // ТУК Е ФИКСЪТ! ВЕЧЕ НАСОЧВАМЕ КЪМ ПРАВИЛНИЯ ДИЗАЙН!
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCardDetailsScreen(brand: brand),
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
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 75,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2), blurRadius: 4),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(4.0),
                                    child: Center(
                                      child: _buildImage(logoUrl),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      brand['name'] ?? 'Неизвестен',
                                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 24),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Долен бутон за ръчно добавяне
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Не намираш своята карта ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      // Тук ще сложим екран за изцяло ръчна карта по-късно
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
                          BoxShadow(color: Colors.black.withOpacity(0.20), offset: const Offset(0, 4), blurRadius: 4),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'ДОБАВИ Я ОТ ТУК',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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