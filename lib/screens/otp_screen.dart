import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';
import 'package:tirbushona_loyalty_app/main.dart';
import 'package:tirbushona_loyalty_app/services/auth_service.dart';
import 'package:tirbushona_loyalty_app/widgets/primary_button.dart';
import 'package:tirbushona_loyalty_app/widgets/bouncing_dots_indicator.dart';
import 'home_screen.dart';
import 'CardOnboardingScreen.dart'; // Добавен импорт за новия екран

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String title;
  final String subtitle;
  final VoidCallback? onSuccess;
  final bool isPhoneChange;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.title = 'Идентификация',
    this.subtitle = 'Изпратен е 4 цифрен код на номер',
    this.onSuccess,
    this.isPhoneChange = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with TickerProviderStateMixin {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;
  int _secondsRemaining = 48;
  bool _isLoading = false;
  late AnimationController _animationController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(4, (_) => TextEditingController());
    _otpFocusNodes = List.generate(4, (_) => FocusNode());
    _startTimer();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
        return true;
      }
      return false;
    });
  }

  void _handleOtpInput(int index, String value) {
    if (value.length == 1) {
      if (index < 3) {
        // Move to next field for boxes 1-3
        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
      } else if (index == 3) {
        // 4th box - trigger submission immediately
        _verifyCode();
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }

  void _verifyCode() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length == 4) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Verify OTP with Supabase
        await _authService.verifyPhoneOtp(widget.phoneNumber, otp);
        
        if (mounted) {
          if (widget.isPhoneChange) {
            // For phone change, show success and return to profile
            _showPhoneChangeSuccess();
          } else {
            // Вземаме ID-то на потребителя
            final userId = Supabase.instance.client.auth.currentUser?.id;
            
            if (userId != null) {
              // 1. Питаме базата дали има вече въведена карта
              final profile = await Supabase.instance.client
                  .from('profiles')
                  .select('physical_card_number')
                  .eq('id', userId)
                  .maybeSingle();

              if (mounted) {
                // 2. Проверяваме резултата
                if (profile != null && 
                    profile['physical_card_number'] != null && 
                    profile['physical_card_number'].toString().trim().isNotEmpty && 
                    profile['physical_card_number'] != 'EMPTY') {
                      
                  // ИМА КАРТА -> отива директно в HomeScreen
                  Navigator.of(context).pushAndRemoveUntil(
                    createSmoothRoute(const HomeScreen()),
                    (route) => false,
                  );
                } else {
                  // НЯМА КАРТА -> отива на екрана за избор (CardOnboardingScreen)
                  Navigator.of(context).pushAndRemoveUntil(
                    createSmoothRoute(const CardOnboardingScreen()),
                    (route) => false,
                  );
                }
              }
            }
          }
        }
      } on Exception catch (error) {
        if (mounted) {
          String errorMessage = 'Възникна грешка при проверката. Опитайте отново.';
          
          if (error.toString().contains('Invalid OTP')) {
            errorMessage = 'Невалиден код. Моля, опитайте отново.';
          } else if (error.toString().contains('OTP expired')) {
            errorMessage = 'Кодът е изтекъл. Поискайте нов код.';
          } else if (error.toString().contains('too many attempts')) {
            errorMessage = 'Твърде много опити. Опитайте по-късно.';
          }
          
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          
          // Clear OTP fields
          for (var controller in _otpControllers) {
            controller.clear();
          }
          
          // Reset focus to first field
          FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showPhoneChangeSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Номерът е потвърден!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Вашият нов номер: ${widget.phoneNumber}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gradientBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Готово',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      appBar: widget.isPhoneChange
          ? AppBar(
              backgroundColor: const Color(0xFFE9EDF4),
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              title: const Text(
                'Потвърждение',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // White Card Container
                  Container(
                    width: 390,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          offset: const Offset(0, -4),
                          blurRadius: 15,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Subtitle
                        Text(
                          '${widget.subtitle}:\n ${widget.phoneNumber}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // OTP Input Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                            (index) => Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _otpFocusNodes[index],
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                onChanged: (value) => _handleOtpInput(index, value),
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Loading Indicator or Timer + Button
                        if (_isLoading)
                          BouncingDotsIndicator(
                            controller: _animationController,
                          )
                        else
                          Column(
                            children: [
                              // Timer Text
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Поискай нов код след : ',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  label: widget.isPhoneChange ? 'Потвърди' : 'Изпрати',
                                  onPressed: _verifyCode,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}