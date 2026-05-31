import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';
import 'package:tirbushona_loyalty_app/screens/cards_screen.dart';
import 'package:tirbushona_loyalty_app/screens/history_screen.dart';
import 'package:tirbushona_loyalty_app/screens/settings_screen.dart';
import 'package:tirbushona_loyalty_app/screens/receipt_details_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCardFlipped = false;
  String _userName = 'Потребител';
  String _physicalCardNumber = '';
  bool _isLoadingProfile = true;
  double _xpayBalance = 0.0;
  StreamSubscription? _profileSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToProfileUpdates();
  }

  /// Subscribe to real-time profile updates via Supabase Stream
  /// Fetches user name, physical card number, and loyalty balance from profiles table
  void _subscribeToProfileUpdates() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _profileSubscription = Supabase.instance.client
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', userId)
          .listen((List<Map<String, dynamic>> data) {
            if (data.isNotEmpty && mounted) {
              final cardNumber = data.first['physical_card_number'] as String? ?? '';
              final loyaltyBalance = double.tryParse(data.first['loyalty_balance']?.toString() ?? '0') ?? 0.0;
              
              setState(() {
                _userName = data.first['full_name'] as String? ?? 'Потребител';
                _physicalCardNumber = cardNumber;
                _xpayBalance = loyaltyBalance;
                _isLoadingProfile = false;
              });
            } else if (mounted) {
              setState(() {
                _userName = 'Потребител';
                _physicalCardNumber = '';
                _xpayBalance = 0.0;
                _isLoadingProfile = false;
              });
            }
          }, onError: (error) {
            debugPrint('Profile stream error: $error');
            if (mounted) {
              setState(() => _isLoadingProfile = false);
            }
          });
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _buildScreenContent(),
        ),
      ),

      // Pixel Perfect Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.savings_outlined, 'Начало'),
              _buildNavItem(1, Icons.credit_card, 'Карти'),
              _buildNavItem(2, Icons.trending_up, 'История'),
              _buildNavItem(3, Icons.person_outline, 'Профил'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const CardsScreen();
      case 2:
        return const HistoryScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return SafeArea(
      child: Column(
        children: [
          // Fixed Header Section (Greeting & Card)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header Section - Dynamic greeting text from Supabase
                if (_isLoadingProfile)
                  SizedBox(
                    height: 22,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'Здравей, $_userName !',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Ще трупаш или приспадаш днес?',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                // Store Card Banner - 3D Flip Animation ONLY
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCardFlipped = !_isCardFlipped;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: _isCardFlipped ? 3.14159 : 0,
                      ),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        final isBack = value > 1.5707; // pi/2
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // Perspective
                            ..rotateY(value),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Front Card
                              _buildCardFront(),
                              // Back Card (With Barcode and Clean Trigger Button inside)
                              if (isBack)
                                Positioned.fill(
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(3.14159),
                                    child: _buildCardBack(),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dynamic Stream Section (Balance and Recent Transactions)
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
                double totalBalance = 0.0;
                List<Map<String, dynamic>> recentReceipts = [];

                if (snapshot.hasData && snapshot.data != null) {
                  final receipts = snapshot.data!;
                  // Взимаме само последните 5 бона за началния екран
                  recentReceipts = receipts.take(5).toList(); 

                  // Пресмятаме общия баланс: Всичко натрупано МИНУС всичко използвано
                  for (var r in receipts) {
                    final points = double.tryParse(r['points_earned']?.toString() ?? '0') ?? 0.0;
                    final used = double.tryParse(r['used_bonus_money']?.toString() ?? '0') ?? 0.0;
                    totalBalance += (points - used);
                  }
                }

                return Column(
                  children: [
                    // Balance Card & Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          // Balance Card
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
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
                                  color: Colors.black.withOpacity(0.20),
                                  offset: const Offset(0, 4),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Натрупана сума',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.savings_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: Supabase.instance.client
                                      .from('receipts')
                                      .stream(primaryKey: ['id'])
                                      .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
                                      .order('date_issued', ascending: false)
                                      .limit(1),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      print('Stream Error: ${snapshot.error}');
                                      return const Text(
                                        '0.00 €',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 2),
                                              blurRadius: 4.0,
                                              color: Color.fromARGB(64, 0, 0, 0),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const Text(
                                        '0.00 €',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 2),
                                              blurRadius: 4.0,
                                              color: Color.fromARGB(64, 0, 0, 0),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    
                                    final rawBalance = snapshot.data![0]['balance_after_transaction'];
                                    final double balance = (rawBalance is num) ? rawBalance.toDouble() : 0.0;
                                    
                                    return Text(
                                      '${balance.toStringAsFixed(2)} €',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 2),
                                            blurRadius: 4.0,
                                            color: Colors.black.withOpacity(0.25),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 35),

                          // History Section Title
                          const Center(
                            child: Text(
                              'История на покупките',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Scrollable Transaction List (Live Data)
                    Expanded(
                      child: recentReceipts.isEmpty
                          ? const Center(
                              child: Text(
                                'Нямате покупки все още.',
                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              itemCount: recentReceipts.length + 1,
                              itemBuilder: (context, index) {
                                // Празно пространство най-отдолу за да не се закрива от менюто
                                if (index == recentReceipts.length) {
                                  return const SizedBox(height: 100);
                                }

                                final receipt = recentReceipts[index];
                                final totalAmount = receipt['total_amount']?.toString() ?? '0.00';
                                final pointsDouble = double.tryParse(receipt['points_earned']?.toString() ?? '0') ?? 0.0;
                                final usedDouble = double.tryParse(receipt['used_bonus_money']?.toString() ?? '0') ?? 0.0;

                                String pointsText = '';
                                bool isAccumulated = true;

                                // Логика за текста на бележката
                                if (usedDouble > 0) {
                                  pointsText = 'Приспаднато: -${usedDouble.toStringAsFixed(2)} €';
                                  isAccumulated = false;
                                } else {
                                  pointsText = 'Натрупано: +${pointsDouble.toStringAsFixed(2)} €';
                                  isAccumulated = true;
                                }

                                // Форматиране на датата
                                String formattedDate = '';
                                try {
                                  if (receipt['date_issued'] != null) {
                                    final parsedDate = DateTime.parse(receipt['date_issued'] as String).toLocal();
                                    formattedDate = "${parsedDate.day.toString().padLeft(2, '0')}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.year}г.";
                                  }
                                } catch (e) {
                                  formattedDate = receipt['date_issued']?.toString() ?? '';
                                }

                                return _buildTransactionCard(
                                  receiptId: receipt['id'].toString(),
                                  date: formattedDate,
                                  totalAmount: '$totalAmount лв.',
                                  pointsText: pointsText,
                                  isAccumulated: isAccumulated,
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.gradientBlue, AppColors.gradientRed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : const Color(0xFFF8FAFC),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.gradientBlue.withOpacity(0.3)
                      : Colors.black.withOpacity(0.03),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      key: const ValueKey('front'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/banner.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    final isCardNumberValid =
        _physicalCardNumber.isNotEmpty && _physicalCardNumber.length > 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCardNumberValid)
            Column(
              children: [
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: _physicalCardNumber,
                  width: 220,
                  height: 65,
                  drawText: false,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showFullscreenBarcode(context, _physicalCardNumber),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner, color: Colors.black54, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'сканирай карта',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  'Няма въведена карта.\nДобавете номер от настройките.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullscreenBarcode(BuildContext context, String barcodeData) {
    if (barcodeData.isEmpty || barcodeData.length <= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Няма валидна карта за сканиране.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeIn,
                ),
              ),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.75,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          offset: const Offset(0, 10),
                          blurRadius: 25,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: BarcodeWidget(
                              barcode: Barcode.code128(),
                              data: barcodeData,
                              width: double.infinity,
                              height: 300,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Затвори',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard({
    required String receiptId,
    required String date,
    required String totalAmount,
    required String pointsText,
    required bool isAccumulated,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptDetailsScreen(receiptId: receiptId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.red.withOpacity(0.1),
        highlightColor: Colors.red.withOpacity(0.05),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBFB),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.savings_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Дата', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                  Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Сума: $totalAmount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    pointsText,
                    style: TextStyle(
                      color: isAccumulated ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}