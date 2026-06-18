import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptDetailsScreen extends StatelessWidget {
  final String receiptId;

  const ReceiptDetailsScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchFullReceipt(receiptId),
      builder: (context, snapshot) {
        // ДОКАТО ЗАРЕЖДА
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // ПРИ ГРЕШКА
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Грешка')),
            body: Center(child: Text('Грешка: ${snapshot.error}')),
          );
        }
        // АКО НЯМА ДАННИ
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Липсва бон')),
            body: const Center(child: Text('Бонът не беше намерен.')),
          );
        }

        final receipt = snapshot.data!;
        
        // 💡 КАТЕГОРИЧНО РАЗПОЗНАВАНЕ: Сторно или нормална продажба
        final bool isStorno = receipt['is_storno'] == true;

        final rawItems = receipt['receipt_items'] as List<dynamic>? ?? [];

        // Разделяме артикулите на нормални и върнати
        final List<dynamic> regularItems = [];
        final List<dynamic> returnedItems = [];

        for (var item in rawItems) {
          final pNameRaw = item['product_name']?.toString() ?? '';
          final pName = pNameRaw.trim().toUpperCase();
          final qty = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
          final uPrice = double.tryParse(item['unit_price']?.toString() ?? '0') ?? 0.0;
          final tPrice = double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0;

          // Игнорираме напълно празни редове, NULL редове или служебни маркировки за отстъпки
          if (pName.isEmpty || pName == 'NULL' || pName == 'ВЪРНАТИ') continue;
          if (pNameRaw.toLowerCase().contains('отстъпка') || pNameRaw.toLowerCase().contains('бонус')) continue;

          final bool isReturned = tPrice < 0 || qty < 0 || uPrice < 0 || pName.contains('ВЪРНАТ');

          if (isReturned) {
            returnedItems.add(item);
          } else {
            regularItems.add(item);
          }
        }

        // Вземаме сигурно стойността на използваните бонус пари
        final usedBonus = double.tryParse(receipt['used_bonus_money']?.toString() ?? '') ??
            double.tryParse(receipt['points_redeemed']?.toString() ?? '0') ?? 0.0;
            
        final pointsEarned = double.tryParse(receipt['points_earned']?.toString() ?? '0') ?? 0;
        final balanceAfterTransaction = double.tryParse(receipt['balance_after_transaction']?.toString() ?? '0') ?? 0;
        final cardNumber = receipt['card_number'] ?? '0000';
        final clientFullName = receipt['profiles']?['full_name'] ?? 'Потребител';

        // ИЗГРАЖДАНЕ НА САМИЯ ЕКРАН
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          // 🎨 ДИНАМИЧЕН APPBAR СПОРЕД ТИПА БОН
          appBar: AppBar(
            title: Text(
              isStorno ? 'СТОРНО БОН № ${receipt['system_num']}' : 'Преглед на бон',
              style: TextStyle(
                color: isStorno ? Colors.white : Colors.black, 
                fontWeight: FontWeight.bold
              ),
            ),
            backgroundColor: isStorno ? const Color(0xFF991B1B) : Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: isStorno ? Colors.white : Colors.black),
          ),
          body: SingleChildScrollView(
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
                  // 🚨 БАНЕР ЗА СТОРНО
                  if (isStorno) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                      child: const Center(
                        child: Text(
                          'АВТОМАТИЧНО СТОРНО',
                          style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

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
                      Text('Сист. № ${receipt['system_num'] ?? '000000'}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  _buildDottedDivider(),

                  // НОРМАЛНИ АРТИКУЛИ
                  if (regularItems.isNotEmpty) ...[
                    const Text('АРТИКУЛИ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...regularItems.map((item) => _buildItemRow(item, isReturned: false)),
                  ],

                  // ВЪРНАТИ АРТИКУЛИ ИЛИ СТОРНИРАНИ
                  if (returnedItems.isNotEmpty) ...[
                    if (regularItems.isNotEmpty) const SizedBox(height: 12),
                    Text(
                      isStorno ? 'СТОРНО!' : 'ВЪРНАТИ', // <--- МАГИЯТА ЗА ЗАГЛАВИЕТО
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 15, 
                        color: isStorno ? const Color(0xFF991B1B) : Colors.red, 
                        letterSpacing: 1.0
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...returnedItems.map((item) => _buildItemRow(item, isReturned: true)),
                  ],

                  _buildDottedDivider(),

                  _buildReceiptRow('НАЧИН НА ПЛАЩАНЕ', receipt['payment_method'] ?? 'В БРОЙ / КАРТА'),
                  const SizedBox(height: 6),
                  
                  // СЕКЦИЯ С ТОТАЛИТЕ
                  _buildTotalSummarySection(receipt, regularItems, returnedItems, usedBonus, isStorno),
                  _buildDottedDivider(),

                  const Center(
                    child: Text(
                      'ЕЛЕКТРОНЕН ПОРТФЕЙЛ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildReceiptRow('Client:', clientFullName),
                  _buildReceiptRow('Карта №:', cardNumber),

                  // ПОРТФЕЙЛ ОПЕРАЦИИ (КРИЯТ СЕ ПРИ СТОРНО)
                  if (!isStorno) ...[
                    if (usedBonus > 0)
                      _buildReceiptRow('Използвана сума:', '-${usedBonus.toStringAsFixed(2)} €', isRed: true, isBold: true),
                    if (pointsEarned > 0)
                      _buildReceiptRow('Натрупана сума:', '+${pointsEarned.toStringAsFixed(2)} €', isGreen: true, isBold: true),
                  ],

                  _buildReceiptRow('Налична сума:', '${balanceAfterTransaction.toStringAsFixed(2)} €', isBold: true),

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
          ),
        );
      },
    );
  }

  Widget _buildTotalSummarySection(Map<String, dynamic> receipt, List<dynamic> regularItems, List<dynamic> returnedItems, double usedBonus, bool isStorno) {
    double grossSum = 0.0;
    double returnedSum = 0.0;

    for (var item in regularItems) {
      final tPrice = double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0;
      grossSum += tPrice;
    }

    for (var item in returnedItems) {
      final tPrice = double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0;
      returnedSum += tPrice.abs();
    }

    final finalTotal = (double.tryParse(receipt['total_amount']?.toString() ?? '0') ?? 0.0).abs();
    
    // Чиста търговска отстъпка = Продукти - Върнати - Бонус пари - Финално платено
    double generalDiscount = grossSum - returnedSum - usedBonus - finalTotal;
    if (generalDiscount < 0.01) generalDiscount = 0.0;

    return Column(
      children: [
        if (grossSum > 0)
          _buildSummaryField('Сума продукти:', '${grossSum.toStringAsFixed(2)} €'),
        
        if (isStorno && returnedSum > 0)
          _buildSummaryField('Стойност сторно:', '${returnedSum.toStringAsFixed(2)} €', textColor: const Color(0xFF991B1B), isBold: true),
        
        if (!isStorno && returnedSum > 0)
          _buildSummaryField('Стойност върнати:', '- ${returnedSum.toStringAsFixed(2)} €', textColor: Colors.red, isBold: true),

        if (usedBonus > 0 && !isStorno)
          _buildSummaryField('Приспаднато от натрупаната сума:', '- ${usedBonus.toStringAsFixed(2)} €', textColor: Colors.orange[800], isBold: true),

        if (generalDiscount > 0.01 && !isStorno)
          _buildSummaryField('Отстъпка:', '- ${generalDiscount.toStringAsFixed(2)} €', textColor: Colors.red, isBold: true),
          
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isStorno ? 'СТОРНИРАНА СУМА:' : 'Обща сума:', 
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
              ),
              Text(
                '${isStorno ? "-" : ""}${finalTotal.toStringAsFixed(2)} €',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18,
                  color: isStorno ? const Color(0xFF991B1B) : Colors.black
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryField(String label, String value, {Color? textColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: textColor, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(fontSize: 13, color: textColor ?? Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
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

    pName = pName.replaceAll(RegExp(r'ВЪРНАТИ\s*', caseSensitive: false), '').trim();
    if (pName.isEmpty) pName = 'Върнат продукт';

    String tPriceFormatted = isReturned && tPrice > 0 ? '-${tPrice.toStringAsFixed(2)} €' : '${tPrice.toStringAsFixed(2)} €'; 

    final Color titleColor = isReturned ? Colors.red : (isPromo ? Colors.green : Colors.black);
    final Color subtitleColor = isReturned ? Colors.red.withOpacity(0.8) : Colors.black54;

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
        // 💡 ВАЖНО: Добавих is_storno към заявката, за да можем да го четем!
        .select('id, company_name, store_name, store_address, vat_number, cashier_name, unp, terminal_num, system_num, payment_method, card_number, total_amount, points_earned, points_redeemed, used_bonus_money, is_storno, balance_after_transaction, receipt_items(*), profiles(full_name)')
        .eq('id', id)
        .maybeSingle(); 
    return response;
  }
}