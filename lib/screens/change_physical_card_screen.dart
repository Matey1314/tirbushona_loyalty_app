import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';

class ChangePhysicalCardScreen extends StatefulWidget {
  final String currentNumber;

  const ChangePhysicalCardScreen({
    super.key,
    required this.currentNumber,
  });

  @override
  State<ChangePhysicalCardScreen> createState() =>
      _ChangePhysicalCardScreenState();
}

class _ChangePhysicalCardScreenState extends State<ChangePhysicalCardScreen> {
  late TextEditingController _newNumberController;
  bool _isNumberValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newNumberController = TextEditingController(text: widget.currentNumber);
    _validateNumber();
    _newNumberController.addListener(_validateNumber);
  }

  @override
  void dispose() {
    _newNumberController.dispose();
    super.dispose();
  }

  void _validateNumber() {
    setState(() {
      // Must be at least 6 digits
      final digitsOnly =
          _newNumberController.text.replaceAll(RegExp(r'\D'), '');
      _isNumberValid = digitsOnly.length >= 6;
    });
  }

  void _saveChanges() async {
    if (!_isNumberValid || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('loyalty_cards').upsert({
          'user_id': user.id,
          'physical_number': _newNumberController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Номерът на картата е обновен успешно!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Грешка при запис: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
          'Смяна физически номер',
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

                // Current Number Section
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
                  widget.currentNumber,
                  style: const TextStyle(
                    color: AppColors.gradientBlue,
                    fontSize: 28,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
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
                              'Внимание!',
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
                        'Този номер генерира баркода необходим за маркиране на картата и нейното споделяне с приятел! Ако случайно го промените се свържете с нас!',
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

                // New Physical Card Number Input
                const Text(
                  'Физически номер',
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
                      color: _newNumberController.text.isEmpty
                          ? const Color(0xFFE5E7EB)
                          : AppColors.gradientBlue,
                      width: 1.5,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: TextField(
                    controller: _newNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 15,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: '10110066',
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
                  _newNumberController.text.isEmpty
                      ? 'Въведете физическия номер'
                      : _isNumberValid
                          ? 'Номерът е валиден'
                          : 'Номерът трябва да съдържа минимум 6 цифри',
                  style: TextStyle(
                    color: _newNumberController.text.isEmpty
                        ? const Color(0xFF9CA3AF)
                        : _isNumberValid
                            ? Colors.green
                            : const Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // Save Button with Gradient
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _isNumberValid
                          ? const LinearGradient(
                              colors: [
                                AppColors.gradientBlue,
                                AppColors.gradientRed,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _isNumberValid ? null : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (_isNumberValid && !_isLoading) ? _saveChanges : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Запази промените',
                                    style: TextStyle(
                                      color: _isNumberValid
                                          ? Colors.white
                                          : const Color(0xFF9CA3AF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
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
