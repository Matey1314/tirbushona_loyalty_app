import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Filter receipts based on selected category
  List<Map<String, dynamic>> _filterReceipts(List<Map<String, dynamic>> receipts) {
    if (_selectedCategory == 'Всички') {
      return receipts;
    }
    return receipts
        .where((receipt) => receipt['store_location'] == _selectedCategory)
        .toList();
  }

  /// Get current month and year string
  String _getCurrentMonthHeader() {
    final now = DateTime.now();
    final months = [
      '',
      'ЯНУАРИ',
      'ФЕВРУАРИ',
      'МАРТ',
      'АПРИЛ',
      'МАЙ',
      'ЮНИ',
      'ЮЛИ',
      'АВГУСТ',
      'СЕПТЕМВРИ',
      'ОКТОМВРИ',
      'НОЕМВРИ',
      'ДЕКЕМВРИ'
    ];
    return '${months[now.month]} ${now.year}г.';
  }

  /// Calculate total for current month
  double _calculateCurrentMonthTotal(List<Map<String, dynamic>> receipts) {
    final now = DateTime.now();
    double total = 0.0;

    for (var receipt in receipts) {
      try {
        if (receipt['date_issued'] != null) {
          final receiptDate =
              DateTime.parse(receipt['date_issued'] as String).toLocal();
          if (receiptDate.month == now.month && receiptDate.year == now.year) {
            final amount = receipt['total_amount'] as num?;
            if (amount != null) {
              total += amount.toDouble();
            }
          }
        }
      } catch (e) {
        // Skip invalid dates
      }
    }

    return total;
  }

  /// Group receipts by month-year header
  Map<String, List<Map<String, dynamic>>> _groupReceiptsByMonth(
      List<Map<String, dynamic>> receipts) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final months = [
      '',
      'ЯНУАРИ',
      'ФЕВРУАРИ',
      'МАРТ',
      'АПРИЛ',
      'МАЙ',
      'ЮНИ',
      'ЮЛИ',
      'АВГУСТ',
      'СЕПТЕМВРИ',
      'ОКТОМВРИ',
      'НОЕМВРИ',
      'ДЕКЕМВРИ'
    ];

    for (var receipt in receipts) {
      try {
        if (receipt['date_issued'] != null) {
          final receiptDate =
              DateTime.parse(receipt['date_issued'] as String).toLocal();
          final monthKey =
              '${months[receiptDate.month]} ${receiptDate.year}г.';

          if (!grouped.containsKey(monthKey)) {
            grouped[monthKey] = [];
          }
          grouped[monthKey]!.add(receipt);
        }
      } catch (e) {
        // Skip invalid dates
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

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
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: userId != null
                      ? Supabase.instance.client
                          .from('receipts')
                          .stream(primaryKey: ['id'])
                          .eq('user_id', userId)
                          .order('date_issued', ascending: false)
                      : const Stream.empty(),
                  builder: (context, snapshot) {
                    double currentMonthTotal = 0.0;

                    if (snapshot.hasData && snapshot.data != null) {
                      currentMonthTotal =
                          _calculateCurrentMonthTotal(snapshot.data!);
                    }

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
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
                            '${currentMonthTotal.toStringAsFixed(2)} лв.',
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
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Category Filter Chips
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
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
          const SizedBox(height: 20),

          // Receipts List Grouped by Month
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: userId != null
                  ? Supabase.instance.client
                      .from('receipts')
                      .stream(primaryKey: ['id'])
                      .eq('user_id', userId)
                      .order('date_issued', ascending: false)
                  : const Stream.empty(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нямате регистрирани покупки все още.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                // Filter receipts based on selected category
                final filteredReceipts = _filterReceipts(snapshot.data!);

                if (filteredReceipts.isEmpty) {
                  return const Center(
                    child: Text(
                      'Няма покупки в тази категория.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                // Group by month
                final groupedByMonth = _groupReceiptsByMonth(filteredReceipts);
                final sortedMonths = groupedByMonth.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: sortedMonths.length,
                  itemBuilder: (context, monthIndex) {
                    final monthKey = sortedMonths[monthIndex];
                    final monthReceipts = groupedByMonth[monthKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Month Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            monthKey,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // Receipts for this month
                        ...monthReceipts.asMap().entries.map((entry) {
                          final receipt = entry.value;
                          final isLast = entry.key == monthReceipts.length - 1;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: isLast ? 24.0 : 12.0,
                            ),
                            child: _buildReceiptCard(receipt),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
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

  Widget _buildReceiptCard(Map<String, dynamic> receipt) {
    final location = receipt['store_location'] as String? ?? 'Обект';
    final totalAmount = receipt['total_amount']?.toString() ?? '0.00';
    final usedBonusMoney = receipt['used_bonus_money']?.toString() ?? '0.00';

    // Format date
    String formattedDate = '';
    try {
      if (receipt['date_issued'] != null) {
        final parsedDate =
            DateTime.parse(receipt['date_issued'] as String).toLocal();
        formattedDate =
            "${parsedDate.day.toString().padLeft(2, '0')}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.year}г.";
      }
    } catch (e) {
      formattedDate = receipt['date_issued']?.toString() ?? '';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          createSmoothRoute(
            const ReceiptDetailsScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Icon - Red Circle with Shopping Cart
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Middle Column - Store Name, Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name
                  Text(
                    location,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Date
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Right Column - Total Amount and Bonus Money
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalAmount лв.',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (double.tryParse(usedBonusMoney) != null &&
                    double.parse(usedBonusMoney) > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+ $usedBonusMoney лв. Натрупано',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}


