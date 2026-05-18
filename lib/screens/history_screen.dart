import 'package:flutter/material.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';
import 'package:tirbushona_loyalty_app/main.dart';
import 'package:tirbushona_loyalty_app/screens/receipt_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedCategory = 'Всички';

  final List<String> categories = [
    'Всички',
    'Домашни потреби',
    'Железария Лагера',
  ];

  // Transaction data with proper structure
  final List<Map<String, String>> allTransactions = [
    // МАРТ 2026г.
    {
      'store': 'Домашни потреби',
      'date': '15.03.2026г.',
      'monthHeader': 'МАРТ 2026г.',
      'amount': '145,80 €',
    },
    {
      'store': 'Железария Лагера',
      'date': '12.03.2026г.',
      'monthHeader': 'МАРТ 2026г.',
      'amount': '89,50 €',
    },
    {
      'store': 'Домашни потреби',
      'date': '08.03.2026г.',
      'monthHeader': 'МАРТ 2026г.',
      'amount': '156,20 €',
    },
    // ФЕВРУАРИ 2026г.
    {
      'store': 'Железария Лагера',
      'date': '28.02.2026г.',
      'monthHeader': 'ФЕВРУАРИ 2026г.',
      'amount': '210,45 €',
    },
    {
      'store': 'Домашни потреби',
      'date': '20.02.2026г.',
      'monthHeader': 'ФЕВРУАРИ 2026г.',
      'amount': '76,30 €',
    },
    {
      'store': 'Железария Лагера',
      'date': '15.02.2026г.',
      'monthHeader': 'ФЕВРУАРИ 2026г.',
      'amount': '134,90 €',
    },
    {
      'store': 'Домашни потреби',
      'date': '10.02.2026г.',
      'monthHeader': 'ФЕВРУАРИ 2026г.',
      'amount': '98,75 €',
    },
    // ЯНУАРИ 2026г.
    {
      'store': 'Домашни потреби',
      'date': '25.01.2026г.',
      'monthHeader': 'ЯНУАРИ 2026г.',
      'amount': '165,50 €',
    },
    {
      'store': 'Железария Лагера',
      'date': '20.01.2026г.',
      'monthHeader': 'ЯНУАРИ 2026г.',
      'amount': '120,00 €',
    },
    {
      'store': 'Домашни потреби',
      'date': '15.01.2026г.',
      'monthHeader': 'ЯНУАРИ 2026г.',
      'amount': '189,99 €',
    },
  ];

  /// Filter transactions based on selected category
  List<Map<String, String>> _getFilteredTransactions() {
    if (_selectedCategory == 'Всички') {
      return allTransactions;
    } else {
      return allTransactions
          .where((transaction) => transaction['store'] == _selectedCategory)
          .toList();
    }
  }

  /// Group filtered transactions by month header
  List<Map<String, dynamic>> _getGroupedByMonth() {
    final filtered = _getFilteredTransactions();
    final Map<String, List<Map<String, String>>> grouped = {};

    for (var transaction in filtered) {
      final month = transaction['monthHeader']!;
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(transaction);
    }

    // Convert to list while preserving order
    final result = <Map<String, dynamic>>[];
    for (var transaction in filtered) {
      final month = transaction['monthHeader']!;
      if (result.isEmpty || result.last['month'] != month) {
        result.add({
          'month': month,
          'transactions': grouped[month] ?? [],
        });
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = _getGroupedByMonth();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'История на покупките',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Monthly Summary Card
                _buildMonthlySummaryCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Category Chips
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return _buildCategoryChip(categories[index]);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Transaction List with Sticky Month Headers
          Expanded(
            child: groupedTransactions.isEmpty
                ? Center(
                    child: Text(
                      'Няма транзакции',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: groupedTransactions.length,
                    itemBuilder: (context, monthIndex) {
                      final monthData = groupedTransactions[monthIndex];
                      final monthName = monthData['month'] as String;
                      final monthTransactions =
                          monthData['transactions'] as List<Map<String, String>>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month Header (Sticky Style)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, bottom: 12.0),
                            child: Text(
                              monthName,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Transactions for this month
                          ...monthTransactions.asMap().entries.map((entry) {
                            final transactionIndex = entry.key;
                            final transaction = entry.value;
                            final isLast = transactionIndex ==
                                monthTransactions.length - 1;

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: isLast ? 24.0 : 12.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    createSmoothRoute(
                                      const ReceiptDetailsScreen(),
                                    ),
                                  );
                                },
                                child: _buildTransactionCard(
                                  storeName: transaction['store']!,
                                  date: transaction['date']!,
                                  amount: transaction['amount']!,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          const Text(
            'Изхарчена сума този месец',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '12,36 €',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
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
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFDC2626),
                    Color(0xFF2563EB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFDC2626).withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String storeName,
    required String date,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Red Circle Icon
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Store Name and Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Amount on the right
          Text(
            amount,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
