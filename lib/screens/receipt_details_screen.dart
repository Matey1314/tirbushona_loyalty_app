import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptDetailsScreen extends StatelessWidget {
  const ReceiptDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // В реално приложение тук ще предаваме ID на бона. 
    // За теста ще заредим директно нашия пълен бон 'BON-007'
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Преглед на бон', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: userId == null
          ? const Center(child: Text('Няма влязъл потребител'))
          : FutureBuilder<List<Map<String, dynamic>>>(
              // Взимаме бележката заедно с нейните артикули
              future: _fetchFullReceipt(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Бонът не беше намерен.'));
                }

                final receipt = snapshot.data!.first;
                final items = receipt['receipt_items'] as List<dynamic>? ?? [];

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
                        // Лого на Тирбушона най-горе
                        Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/banner.png', // Твоето лого
                                height: 60,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              const Text('Пазарувай с усмивка ;)', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Данни на Фирмата и Обекта
                        Center(
                          child: Column(
                            children: [
                              Text(receipt['company_name'] ?? 'М.С ИНЖЕНЕРИНГ ООД', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(receipt['store_location'] ?? 'Железария Лагера', style: const TextStyle(fontSize: 13)),
                              Text('ЗДДС № ${receipt['vat_number'] ?? 'BG130863654'}', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        _buildDottedDivider(),

                        // Фискална информация за оператора
                        _buildReceiptRow('ИМЕ ОПЕРАТОР', receipt['operator_name'] ?? 'Касиер 1'),
                        _buildReceiptRow('УНП:', receipt['unp'] ?? 'ED303495-0043-0015531'),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Терминал № ${receipt['terminal_num'] ?? '1'}', style: const TextStyle(fontSize: 13)),
                            Text('Сист. № ${receipt['system_num'] ?? '407970'}', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        _buildDottedDivider(),

                        // СПИСЪК С АРТИКУЛИ
                        const Text('АРТИКУЛИ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        ...items.map((item) {
                          final pName = item['product_name'] ?? 'Продукт';
                          final qty = item['quantity'] ?? 1;
                          final uPrice = double.tryParse(item['unit_price']?.toString() ?? '0') ?? 0.0;
                          final tPrice = double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${qty}x ${uPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                    Text('${tPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        _buildDottedDivider(),

                        // ПЛАЩАНЕ И ОБЩА СУМА
                        _buildReceiptRow('НАЧИН НА ПЛАЩАНЕ', receipt['payment_method'] ?? 'В БРОЙ / КАРТА'),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ОБЩА СУМА ЕВРО', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('${receipt['total_amount']} €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        _buildDottedDivider(),

                        // ЕЛЕКТРОНЕН ПОРТФЕЙЛ (ЛОЯЛНА ПРОГРАМА)
                        const Center(
                          child: Text('ЕЛЕКТРОНЕН ПОРТФЕЙЛ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                        ),
                        const SizedBox(height: 10),
                        _buildReceiptRow('Клиент:', receipt['client_name'] ?? 'Потребител'),
                        _buildReceiptRow('Карта №:', receipt['card_number'] ?? '0000'),
                        
                        // Динамично показваме натрупано или приспаднато
                        if (double.parse(receipt['used_bonus_money']?.toString() ?? '0') > 0)
                          _buildReceiptRow('Приспаднато:', '${receipt['used_bonus_money']} €', isRed: true)
                        else
                          _buildReceiptRow('Натрупано:', '${receipt['points_earned']} €', isGreen: true),

                        _buildReceiptRow('Налично:', '${receipt['remaining_bonus_balance']} €', isBold: true),
                        
                        _buildDottedDivider(),
                        const Center(
                          child: Text('Благодарим Ви за покупката!', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Помощен метод за редове в касовия бон
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
          Text(value, style: TextStyle(fontSize: 13, color: textColor, fontWeight: (isBold || isGreen || isRed) ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // Пунктирана фискална линия
  Widget _buildDottedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: List.generate(
          30,
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

  // Функция за изтегляне на бележката + продуктите от Supabase чрез връзката им
  Future<List<Map<String, dynamic>>> _fetchFullReceipt() async {
    final response = await Supabase.instance.client
        .from('receipts')
        .select('*, receipt_items(*)')
        .eq('receipt_number', 'BON-007');
    return List<Map<String, dynamic>>.from(response);
  }
}