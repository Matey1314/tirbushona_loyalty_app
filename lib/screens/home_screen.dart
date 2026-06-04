import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';
import 'package:tirbushona_loyalty_app/screens/cards_screen.dart';
import 'package:tirbushona_loyalty_app/screens/history_screen.dart';
import 'package:tirbushona_loyalty_app/screens/settings_screen.dart';
import 'package:tirbushona_loyalty_app/screens/receipt_details_screen.dart';
import 'dart:async';
import 'dart:math' show sin, pi;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isCardFlipped = false;
  String _userName = 'Потребител';
  String _physicalCardNumber = '';
  bool _isLoadingProfile = true;
  StreamSubscription? _profileSubscription;
  late AnimationController _bannerShakeController;
  late Animation<double> _bannerShakeAnimation;

  // ПРОМЕНЛИВИ ЗА ОЦЕНЯВАНЕТО
  StreamSubscription? _receiptsSubscription;
  bool _isShowingRatingDialog = false;

  @override
  void initState() {
    super.initState();
    _subscribeToProfileUpdates();
    _initializeBannerShakeAnimation();
    
    // СТАРТИРАМЕ СЛУШАЛКАТА ЗА НОВИ БЕЛЕЖКИ
    _listenForUnratedReceipts();
  }

  void _initializeBannerShakeAnimation() {
    _bannerShakeController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _bannerShakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bannerShakeController, curve: Curves.easeInOut),
    );
    
    _bannerShakeController.forward();
  }

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
              
              setState(() {
                _userName = data.first['full_name'] as String? ?? 'Потребител';
                _physicalCardNumber = cardNumber;
                _isLoadingProfile = false;
              });
            } else if (mounted) {
              setState(() {
                _userName = 'Потребител';
                _physicalCardNumber = '';
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
    _bannerShakeController.dispose();
    _receiptsSubscription?.cancel();
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
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
                            Colors.black.withValues(alpha: 0.3),
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
                              _buildCardFront(),
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
                List<Map<String, dynamic>> recentReceipts = [];

                if (snapshot.hasData && snapshot.data != null) {
                  final receipts = snapshot.data!;
                  recentReceipts = receipts.take(5).toList(); 
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [AppColors.gradientBlue, AppColors.gradientRed],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  offset: const Offset(0, 4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Натрупана сума',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.savings_outlined, color: Colors.white, size: 24),
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
                                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const Text(
                                        '0.00 €',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(offset: Offset(0, 2), blurRadius: 4.0, color: Color.fromARGB(64, 0, 0, 0)),
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
                                            color: Colors.black.withValues(alpha: 0.25),
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
                          const Center(
                            child: Text(
                              'История на покупките',
                              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

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
                                if (index == recentReceipts.length) {
                                  return const SizedBox(height: 100);
                                }

                                final receipt = recentReceipts[index];
                                final totalAmount = receipt['total_amount']?.toString() ?? '0.00';
                                final pointsDouble = double.tryParse(receipt['points_earned']?.toString() ?? '0') ?? 0.0;
                                final usedDouble = double.tryParse(receipt['used_bonus_money']?.toString() ?? '0') ?? 0.0;

                                String pointsText = '';
                                bool isAccumulated = true;

                                if (usedDouble > 0) {
                                  pointsText = 'Приспаднато: -${usedDouble.toStringAsFixed(2)} €';
                                  isAccumulated = false;
                                } else {
                                  pointsText = 'Натрупано: +${pointsDouble.toStringAsFixed(2)} €';
                                  isAccumulated = true;
                                }

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
                                  totalAmount: '$totalAmount €',
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
                      ? AppColors.gradientBlue.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.03),
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
    return AnimatedBuilder(
      animation: _bannerShakeAnimation,
      builder: (context, child) {
        final shakeOffset = sin(_bannerShakeAnimation.value * pi * 8) * 4;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: Container(
        key: const ValueKey('front'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
      ),
    );
  }

  Widget _buildCardBack() {
    final isCardNumberValid = _physicalCardNumber.isNotEmpty && _physicalCardNumber.length > 3;

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
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
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
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullscreenBarcode(BuildContext context, String barcodeData) {
    if (barcodeData.isEmpty || barcodeData.length <= 3) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: ModalRoute.of(context)!.animation!, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: ModalRoute.of(context)!.animation!, curve: Curves.easeIn),
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
                        BoxShadow(color: Colors.black.withValues(alpha: 0.20), offset: const Offset(0, 10), blurRadius: 25),
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
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Затвори',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
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
            MaterialPageRoute(builder: (context) => ReceiptDetailsScreen(receiptId: receiptId)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.red.withValues(alpha: 0.1),
        highlightColor: Colors.red.withValues(alpha: 0.05),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBFB),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, 4), blurRadius: 4),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
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

  // =========================================================
  // ЛОГИКА ЗА ОЦЕНЯВАНЕ НА ПОСЕЩЕНИЕТО
  // =========================================================

  void _listenForUnratedReceipts() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _receiptsSubscription = Supabase.instance.client
        .from('receipts')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('date_issued', ascending: false)
        .limit(1)
        .listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty && mounted) {
        final latestReceipt = data.first;
        final rating = latestReceipt['rating'];
        final dateIssuedStr = latestReceipt['date_issued'];

        // Търсим NULL или 0
        if ((rating == null || rating == 0) && dateIssuedStr != null && !_isShowingRatingDialog) {
          final dateIssued = DateTime.parse(dateIssuedStr.toString()).toLocal();
          final now = DateTime.now();
          
          if (now.difference(dateIssued).inHours.abs() <= 4) {
            _isShowingRatingDialog = true; // Заключваме веднага, за да не се дублира
            
            // Изчакваме 800мс за да може списъкът да се обнови плавно първо
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                _showRatingBottomSheet(latestReceipt['id'].toString());
              }
            });
          }
        }
      }
    });
  }

  void _showRatingBottomSheet(String receiptId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                'Оценете преживяването си',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Вашето мнение ни помага да бъдем по-добри!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('😞 Разочарован', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('Възхитен 😍', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 12,
                children: List.generate(10, (index) {
                  final ratingValue = index + 1;
                  final double normalized = index / 9; 
                  final Color bgColor = Color.lerp(Colors.red[500], Colors.green[600], normalized)!;

                  return GestureDetector(
                    onTap: () => _submitRating(receiptId, ratingValue),
                    child: Container(
                      width: 42,
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bgColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: bgColor.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: Text(
                        '$ratingValue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: bgColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 35),
              TextButton(
                onPressed: () => _dismissRating(receiptId), // ВИКАМЕ НОВАТА ФУНКЦИЯ ЗА ОТКАЗ
                child: const Text(
                  'Не сега',
                  style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) setState(() => _isShowingRatingDialog = false);
    });
  }

  Future<void> _submitRating(String receiptId, int rating) async {
    Navigator.pop(context); // Затваряме менюто

    try {
      final idToUpdate = int.tryParse(receiptId) ?? receiptId;

      final result = await Supabase.instance.client
          .from('receipts')
          .update({'rating': rating})
          .eq('id', idToUpdate)
          .select();

      if (result.isEmpty) {
        debugPrint('ГРЕШКА: Supabase не обнови нищо.');
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Благодарим ви за оценката! ❤️', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    } catch (e) {
      debugPrint('Грешка при запис на рейтинг: $e');
    }
  }

  // НОВАТА ФУНКЦИЯ ЗА ЗАПИСВАНЕ НА ОТКАЗ (-1)
  Future<void> _dismissRating(String receiptId) async {
    Navigator.pop(context); // Скриваме менюто веднага

    try {
      final idToUpdate = int.tryParse(receiptId) ?? receiptId;
      
      // Записваме -1 тихо, за да не се показва повече този прозорец за тази бележка
      await Supabase.instance.client
          .from('receipts')
          .update({'rating': -1})
          .eq('id', idToUpdate);
    } catch (e) {
      debugPrint('Грешка при отказване на рейтинг: $e');
    }
  }
}