import 'package:flutter/material.dart';

class ReceiptDetailsScreen extends StatefulWidget {
  const ReceiptDetailsScreen({super.key});

  @override
  State<ReceiptDetailsScreen> createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends State<ReceiptDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 24,
          ),
        ),
        title: const Text(
          'Електронен касов бон',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Action Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Свали PDF" Button - Red
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFDC2626),
                            Color(0xFFB91C1C),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Implement PDF download functionality
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.file_download,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Свали PDF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // "Сподели PDF" Button - Disabled (Light Grey)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Implement PDF share functionality
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.share_outlined,
                                  color: Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Сподели PDF',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Receipt Canvas - Scrollable White Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: SizedBox(
                          width: 335,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ======== HEADER LOGO ========
                              Center(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 60,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.credit_card,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ======== MERCHANT METADATA (CENTERED) ========
                              Text(
                                'М.С ИНЖЕНЕРИНГ ООД',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'София, жк. "ЛАГЕРА"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              Text(
                                'ИМЕ МАГАЗИН',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              Text(
                                'АДРЕС МАГАЗИН',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              Text(
                                'ЗДДС № BG130863654',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // ======== DIVIDER ========
                              Text(
                                '------------------------------------------',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // ======== OPERATOR & SESSION METADATA ========
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ИМЕ ОПЕРАТОР',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        color: Colors.black,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    Text(
                                      'УНП: ED303495-0043-0015531',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        color: Colors.black,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Terminal & System Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Терминал    №1',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    'Сист. № 407970',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              // Time Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Начало: 09:29',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    'Край: 09:30',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // ======== DIVIDER ========
                              Text(
                                '------------------------------------------',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // ======== PRODUCTS LIST ========
                              // Product 1
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'БАТЕРИЯ АЛКАЛНА АА',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '2x 0,86',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.black,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                      Text(
                                        '1,72',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.black,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Product 2
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ГУМЕНА ТОПКА СКОК',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '1x 1,90',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.black,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                      Text(
                                        '1,90',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.black,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Product 3
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'МАРКЕРИ КОМПЛЕКТ',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '1x 5,62',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.black,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                      Text(
                                        '5,62',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.black,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Product 4
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'РАНИЦА УЧИЛИЩНА',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '1x 8,00',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.black,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                      Text(
                                        '8,00',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.black,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // ======== DIVIDER ========
                              Text(
                                '------------------------------------------',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // ======== PAYMENT METHOD ========
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'НАЧИН НА ПЛАЩАНЕ',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    'В БРОЙ / КАРТА',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // ======== TOTAL PRICE (BOLD & LARGE) ========
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ОБЩА СУМА ЕВРО',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '17.24',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 16,
                                      height: 1.4,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ======== DIVIDER ========
                              Text(
                                '------------------------------------------',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ======== LOYALTY WALLET ========
                              Text(
                                'ЕЛЕКТРОНЕН ПОРТФЕЙЛ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Client Info
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Клиент:',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    'Матей Пандъров',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              // Card Number
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Карта №:',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    '1352',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              // Points Accumulated
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Натрупано:',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    '0.86',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              // Available Balance
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Налично:',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    '14.32',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Date & Time Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '05-03-2026',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    '09:30:07',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ======== DIVIDER ========
                              Text(
                                '------------------------------------------',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ======== QR CODE PLACEHOLDER ========
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'QR CODE',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ======== FISCAL TEXT ========
                              Text(
                                'ФИСКАЛЕН БОН',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
