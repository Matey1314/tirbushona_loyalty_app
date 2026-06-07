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
          final rawItems = receipt['receipt_items'] as List<dynamic>? ?? [];

          // Разделяме артикулите на нормални и върнати
          final List<dynamic> regularItems = [];
          final List<dynamic> returnedItems = [];

          for (var item in rawItems) {
            final pName = item['product_name']?.toString().toUpperCase() ?? '';
            final qty = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
            final uPrice = double.tryParse(item['unit_price']?.toString() ?? '0') ?? 0.0;
            final tPrice = double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0;

            // Игнорираме, ако софтуерът е пратил празен ред с текст "ВЪРНАТИ" и нулева цена
            if (pName == 'ВЪРНАТИ' && tPrice == 0 && qty == 0) continue;

            final bool isReturned = tPrice < 0 || qty < 0 || uPrice < 0 || pName.contains('ВЪРНАТ');

            if (isReturned) {
              returnedItems.add(item);
            } else {
              regularItems.add(item);
            }
          }

          final usedBonus = double.tryParse(receipt['points_redeemed']?.toString() ?? '0') ?? 0;
          final pointsEarned = double.tryParse(receipt['points_earned']?.toString() ?? '0') ?? 0;
          
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
                    color: Colors.black.withValues(alpha: 0.05),
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

                  // НОРМАЛНИ АРТИКУЛИ
                  if (regularItems.isNotEmpty) ...[
                    const Text('АРТИКУЛИ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...regularItems.map((item) => _buildItemRow(item, isReturned: false)),
                  ],

                  // ВЪРНАТИ АРТИКУЛИ (Отделени точно както на касовия бон)
                  if (returnedItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'ВЪРНАТИ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 4),
                    ...returnedItems.map((item) => _buildItemRow(item, isReturned: true)),
                  ],

                  _buildDottedDivider(),

                  _buildReceiptRow('НАЧИН НА ПЛАЩАНЕ', receipt['payment_method'] ?? 'В БРОЙ / КАРТА'),
                  const SizedBox(height: 6),
                  _buildTotalSummarySection(receipt, regularItems, returnedItems),
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
                    _buildReceiptRow('Използван бонус:', '-${usedBonus.toStringAsFixed(2)} €', isRed: true, isBold: true)
                  else if (pointsEarned > 0)
                    _buildReceiptRow('Натрупан бонус:', '+${pointsEarned.toStringAsFixed(2)} €', isGreen: true, isBold: true),

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

  Widget _buildTotalSummarySection(Map<String, dynamic> receipt, List<dynamic> regularItems, List<dynamic> returnedItems) {
    double grossSum = 0.0;
    double returnedSum = 0.0;

    for (var item in regularItems) {
      final tPrice = double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0;
      grossSum += tPrice;
    }

    for (var item in returnedItems) {
      final tPrice = double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0;
      returnedSum += tPrice.abs(); // Пазим я като положително число за лесно показване
    }

    final finalTotal = double.tryParse(receipt['total_amount']?.toString() ?? '0') ?? 0.0;
    final generalDiscount = grossSum - returnedSum - finalTotal;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Сума продукти:', style: TextStyle(fontSize: 13)),
              Text(
                '${grossSum.toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        
        if (returnedSum > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Стойност върнати:',
                  style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                ),
                Text(
                  '- ${returnedSum.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        if (generalDiscount > 0.01)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Отстъпка:',
                  style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                ),
                Text(
                  '- ${generalDiscount.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
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

  Widget _buildItemRow(dynamic item, {required bool isReturned}) {
    String pName = item['product_name']?.toString() ?? 'Продукт';
    final qty = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
    final uPrice = double.tryParse(item['unit_price']?.toString() ?? '0') ?? 0.0;
    final tPrice = double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0;
    final isPromo = item['is_promo'] as bool? ?? false;

    // Изчистваме системни текстове "ВЪРНАТИ" от самото име на продукта, ако софтуерът ги е залепил там (cross-platform съвместимо)
    pName = pName.replaceAll(RegExp(r'ВЪРНАТИ\s*', caseSensitive: false), '').trim();
    if (pName.isEmpty) pName = 'Върнат продукт';

    String tPriceFormatted;
    if (isReturned && tPrice > 0) {
      tPriceFormatted = '-${tPrice.toStringAsFixed(2)} €';
    } else {
      tPriceFormatted = '${tPrice.toStringAsFixed(2)} €'; 
    }

    final Color titleColor = isReturned ? Colors.red : (isPromo ? Colors.green : Colors.black);
    final Color subtitleColor = isReturned ? Colors.red.withValues(alpha: 0.8) : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: titleColor,
                  ),
                ),
              ),
              if (isPromo && !isReturned)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: const Text(
                    'PROMO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${qty.abs().toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2)}x ${uPrice.abs().toStringAsFixed(2)}', 
                   style: TextStyle(color: subtitleColor, fontSize: 13)),
              Text(tPriceFormatted, 
                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titleColor)),
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