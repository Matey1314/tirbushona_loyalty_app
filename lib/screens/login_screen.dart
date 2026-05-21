import 'package:flutter/material.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';
import 'package:tirbushona_loyalty_app/main.dart';
import 'package:tirbushona_loyalty_app/services/auth_service.dart';
import 'package:tirbushona_loyalty_app/widgets/primary_button.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Handles the phone number submission to send SMS OTP
  void _handleSendOtp() async {
    final phoneNumber = _phoneController.text.trim();

    // Validate input
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Моля, въведете номер на телефон.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Basic phone number validation (should start with + or be 10-15 digits)
    if (phoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Моля, въведете валиден номер на телефон.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send OTP to phone number
      await _authService.signInWithPhone(phoneNumber);

      // If successful, navigate to OTP screen
      if (mounted) {
        Navigator.of(context).push(
          createSmoothRoute(
            OtpScreen(
              phoneNumber: phoneNumber,
              title: 'Потвърждение',
              subtitle: 'Изпратен е 4 цифрен код на номер',
              isPhoneChange: false,
            ),
          ),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        // Show error message in SnackBar
        String errorMessage = 'Възникна грешка при изпращане. Опитайте отново.';

        if (error.toString().contains('invalid phone')) {
          errorMessage = 'Невалиден номер на телефон.';
        } else if (error.toString().contains('Too many requests')) {
          errorMessage = 'Твърде много опити. Опитайте отново по-късно.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                  ),

                  // 2. SizedBox
                  const SizedBox(height: 40),

                  // 3. "Вход в приложението" Text
                  const Text(
                    'Вход в приложението',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 4. SizedBox
                  const SizedBox(height: 30),

                  // 5. White Card Container with Form
                  Container(
                    width: double.infinity,
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
                      children: [
                        // Phone Number Input Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                'Телефонен номер',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                enabled: !_isLoading,
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: '+359 895 315 595',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFFB0B9C8),
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: _isLoading ? 'Изпращане...' : 'Изпрати ',
                            onPressed: _handleSendOtp,
                            isLoading: _isLoading,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Terms and Privacy RichText
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'С натискането на „Изпрати ", Вие се съгласявате с нашите ',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Условия за ползване',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: ' и ',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Политика за поверителност',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
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
