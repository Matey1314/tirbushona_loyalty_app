import 'package:flutter/material.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';
import 'package:tirbushona_loyalty_app/main.dart';
import 'package:tirbushona_loyalty_app/widgets/primary_button.dart';
import 'package:tirbushona_loyalty_app/screens/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleNextPress() {
    // Get the phone number and remove whitespace
    String phoneNumber = _phoneController.text.replaceAll(' ', '').trim();

    // Validate: Check if empty or less than 9 characters
    if (phoneNumber.isEmpty || phoneNumber.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Моля, въведете валиден телефонен номер.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Navigate to OTP Screen immediately
    Navigator.of(context).push(
      createSmoothRoute(
        const OtpScreen(),
      ),
    );
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
                        // Phone Input Fields Section
                        Row(
                          children: [
                            // Code Field
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 12.0),
                                    child: Text(
                                      'Код',
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          '+359',
                                          style: TextStyle(
                                            color: AppColors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF6B7280),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Phone Number Field
                            Expanded(
                              flex: 2,
                              child: Column(
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
                                      style: const TextStyle(
                                        color: AppColors.black,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0 8 9 9 8 8 3 5 2 2',
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
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: 'Изпрати',
                            onPressed: _handleNextPress,
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
                                text: 'С натискането на „Изпрати", Вие се съгласявате с нашите ',
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
