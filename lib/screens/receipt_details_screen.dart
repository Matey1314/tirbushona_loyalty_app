import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptDetailsScreen extends StatelessWidget {
  final String receiptId;

  const ReceiptDetailsScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Преглед на бон',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchFullReceipt(receiptId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Грешка: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Бонът не беше намерен.'));
          }

          final receipt = snapshot.data!;
          final items = receipt['receipt_items'] as List<dynamic>? ?? [];

          final usedBonus = double.tryParse(receipt['points_redeemed']?.toString() ?? '0') ?? 0;
          final pointsEarned = double.tryParse(receipt['points_earned']?.toString() ?? '0') ?? 0;
          
          // Display raw balance_after_transaction from database - NO CALCULATIONS
          final balanceAfterTransaction = double.tryParse(receipt['balance_after_transaction']?.toString() ?? '0') ?? 0;
          final cardNumber = receipt['card_number'] ?? '0000';
          final clientFullName = receipt['profiles']?['full_name'] ?? 'Потребител';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.receipt_long, size: 50, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Пазарувай с усмивка ;)',
                          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  _buildDottedDivider(),

                  Center(
                    child: Column(
                      children: [
                        Text(
                          receipt['company_name'] ?? 'М.С ИНЖЕНЕРИНГ ООД',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(receipt['store_name'] ?? 'Железария Лагера', style: const TextStyle(fontSize: 13)),
                        if (receipt['store_address'] != null)
                          Text(receipt['store_address'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        Text('ЗДДС № ${receipt['vat_number'] ?? 'BG130863654'}', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  _buildDottedDivider(),

                  _buildReceiptRow('ИМЕ ОПЕРАТОР', receipt['cashier_name'] ?? '-'),
                  _buildReceiptRow('УНП:', receipt['unp'] ?? '-'),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Терминал № ${receipt['terminal_num'] ?? '1'}', style: const TextStyle(fontSize: 13)),
                      Text('Сист. № ${receipt['system_num'] ?? '407970'}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  _buildDottedDivider(),

                  const Text('АРТИКУЛИ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...items.map((item) => _buildItemRow(item)),
                  _buildDottedDivider(),

                  _buildReceiptRow('НАЧИН НА ПЛАЩАНЕ', receipt['payment_method'] ?? 'В БРОЙ / КАРТА'),
                  const SizedBox(height: 6),
                  _buildTotalSummarySection(receipt, items),
                  _buildDottedDivider(),

                  const Center(
                    child: Text(
                      'ЕЛЕКТРОНЕН ПОРТФЕЙЛ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildReceiptRow('Клиент:', clientFullName),
                  _buildReceiptRow('Карта №:', cardNumber),

                  if (usedBonus > 0)
                    _buildReceiptRow('Приспаднато:', '-${usedBonus.toStringAsFixed(2)} €', isRed: true, isBold: true)
                  else if (pointsEarned > 0)
                    _buildReceiptRow('Натрупано:', '+${pointsEarned.toStringAsFixed(2)} €', isGreen: true, isBold: true),

                  // Display raw balance_after_transaction from database - NO CALCULATIONS
                  _buildReceiptRow('Налично:', '${balanceAfterTransaction.toStringAsFixed(2)} €', isBold: true),

                  _buildDottedDivider(),
                  const Center(
                    child: Text(
                      'Благодарим Ви за покупката!',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalSummarySection(Map<String, dynamic> receipt, List<dynamic> items) {
    // Calculate original sum from all items
    final originalSum = items.fold<double>(
      0.0,
      (sum, item) => sum + (double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0),
    );

    // Get final total amount
    final finalTotal = double.tryParse(receipt['total_amount']?.toString() ?? '0') ?? 0.0;

    // Calculate deducted amount
    final deductedAmount = originalSum - finalTotal;

    return Column(
      children: [
        // Row 1: Сума (Original Sum)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Сума:', style: TextStyle(fontSize: 13)),
              Text(
                '${originalSum.toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        // Row 2: Приспаднато (Deducted - in RED)
        if (deductedAmount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Приспаднато:',
                  style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                ),
                Text(
                  '- ${deductedAmount.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        // Row 3: Обща сума (Final Total)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Обща сума:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(
                '${finalTotal.toStringAsFixed(2)} €',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isGreen = false, bool isRed = false, bool isBold = false}) {
    Color textColor = Colors.black;
    if (isGreen) textColor = Colors.green;
    if (isRed) textColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: (isBold || isGreen || isRed) ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(dynamic item) {
    final pName = item['product_name'] ?? 'Продукт';
    final qty = item['quantity'] ?? 1;
    final uPrice = double.tryParse(item['unit_price']?.toString() ?? '0') ?? 0.0;
    final tPrice = double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${qty}x ${uPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
              Text('${tPrice.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDottedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: List.generate(
          40,
          (index) => Expanded(
            child: Container(
              color: index % 2 == 0 ? Colors.transparent : Colors.grey[400],
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchFullReceipt(String id) async {
    final response = await Supabase.instance.client
        .from('receipts')
        .select('id, company_name, store_name, store_address, vat_number, cashier_name, unp, terminal_num, system_num, payment_method, card_number, total_amount, points_earned, points_redeemed, balance_after_transaction, receipt_items(*), profiles(full_name)')
        .eq('id', id)
        .maybeSingle(); 
    return response;
  }
}