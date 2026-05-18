import 'package:flutter/material.dart';
import 'package:tirbushona_loyalty_app/core/theme/app_colors.dart';

class ChangeLogisticNumberScreen extends StatefulWidget {
  final String currentNumber;

  const ChangeLogisticNumberScreen({
    super.key,
    required this.currentNumber,
  });

  @override
  State<ChangeLogisticNumberScreen> createState() =>
      _ChangeLogisticNumberScreenState();
}

class _ChangeLogisticNumberScreenState
    extends State<ChangeLogisticNumberScreen> {
  late TextEditingController _newNumberController;
  bool _isNumberValid = false;

  @override
  void initState() {
    super.initState();
    _newNumberController = TextEditingController();
    _newNumberController.addListener(_validateNumber);
  }

  @override
  void dispose() {
    _newNumberController.dispose();
    super.dispose();
  }

  void _validateNumber() {
    setState(() {
      // Must be exactly 4 digits
      final digitsOnly =
          _newNumberController.text.replaceAll(RegExp(r'\D'), '');
      _isNumberValid = digitsOnly.length == 4;
    });
  }

  void _saveChanges() {
    if (_isNumberValid) {
      final newNumber = _newNumberController.text;
      Navigator.pop(context, newNumber);
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
          'Смяна логистичен номер',
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
                        'Този номер е ключът към вашият профил в системата ни! Ако неволно го промените се свържете с нас!',
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

                // New Logistic Number Input
                const Text(
                  'Логистичен номер',
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
                    maxLength: 7,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: '0 0 0 0',
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
                      ? 'Въведете логистичния номер'
                      : _isNumberValid
                          ? 'Номерът е валиден'
                          : 'Номерът трябва да съдържа точно 4 цифри',
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
                        onTap: _isNumberValid ? _saveChanges : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text(
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
