import 'package:flutter/material.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';
import 'package:tirbushona_loyalty_app/screens/otp_screen.dart';
import 'package:tirbushona_loyalty_app/main.dart';

class ChangePhoneScreen extends StatefulWidget {
  final String currentPhone;
  const ChangePhoneScreen({super.key, required this.currentPhone});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  late TextEditingController _newPhoneController;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _newPhoneController = TextEditingController();
    _newPhoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _newPhoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      // Phone must be at least 10 digits
      _isPhoneValid = _newPhoneController.text.replaceAll(RegExp(r'\D'), '').length >= 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      appBar: AppBar(
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
          'Промяна номер',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Current Phone Number Section
                const Text(
                  'Текущ номер',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.currentPhone,
                  style: const TextStyle(
                    color: AppColors.gradientBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Warning Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Важно!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Промяната на номера е критична операция. Ще получите SMS код за потвърждение на новия номер.',
                        style: TextStyle(
                          color: Color(0xFFFFEBEE),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // New Phone Number Input
                const Text(
                  'Нов номер',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                    border: Border.all(
                      color: _newPhoneController.text.isEmpty
                          ? const Color(0xFFE5E7EB)
                          : AppColors.gradientBlue,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: TextField(
                    controller: _newPhoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 13,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: '+359 87 753 73 00',
                      hintStyle: const TextStyle(
                        color: Color(0xFFC4B5FD),
                        fontSize: 14,
                      ),
                      counterText: '',
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _newPhoneController.text.isEmpty
                      ? 'Въведете новия номер'
                      : _isPhoneValid
                          ? 'Номерът е валидна'
                          : 'Номерът трябва да съдържа минимум 10 цифри',
                  style: TextStyle(
                    color: _newPhoneController.text.isEmpty
                        ? const Color(0xFF9CA3AF)
                        : _isPhoneValid
                            ? Colors.green
                            : const Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPhoneValid
                        ? () {
                            Navigator.of(context).push(
                              createSmoothRoute(
                                OtpScreen(
                                  phoneNumber: _newPhoneController.text,
                                  title: 'Потвърждение',
                                  subtitle: 'Кодът беше изпратен на',
                                  isPhoneChange: true,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradientBlue,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Запази промените',
                      style: TextStyle(
                        color: _isPhoneValid ? Colors.white : const Color(0xFF9CA3AF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
