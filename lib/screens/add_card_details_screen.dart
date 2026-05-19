import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tirbushona_loyalty_app/services/cards_service.dart';

class AddCardDetailsScreen extends StatefulWidget {
  final Map<String, String> brand;

  const AddCardDetailsScreen({
    super.key,
    required this.brand,
  });

  @override
  State<AddCardDetailsScreen> createState() => _AddCardDetailsScreenState();
}

class _AddCardDetailsScreenState extends State<AddCardDetailsScreen> {
  String? _cardNumber;
  String? _additionalNotes;
  final ImagePicker _picker = ImagePicker();
  String? _cardImagePath;

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
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: const Text(
          'Добави карта',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. Card Preview Container
            Center(
              child: Container(
                width: 343,
                height: 215,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      offset: const Offset(0, 10),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      widget.brand['logo']!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 15),

            // 2. Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 3. Action Buttons
            _buildOptionButton(
              CupertinoIcons.barcode,
              'Сканирай баркода на картата',
              onTap: _scanBarcode,
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              Icons.camera_alt_outlined,
              'Добави от Снимка / Галерия',
              onTap: _pickImageFromGallery,
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              Icons.keyboard_outlined,
              'Добави ръчно номера на картата',
              onTap: () {
                _showInputBottomSheet(
                  context,
                  'Въведи номер',
                  'Напр. 123456789',
                  false,
                  (value) {
                    setState(() => _cardNumber = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Номерът е запазен!')),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              Icons.edit_outlined,
              'Допълнителни бележки',
              onTap: () {
                _showInputBottomSheet(
                  context,
                  'Бележки',
                  'Напиши нещо тук...',
                  true,
                  (value) {
                    setState(() => _additionalNotes = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Бележката е запазена!')),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // Card Number Display (if scanned or entered)
            if (_cardNumber != null && _cardNumber!.isNotEmpty)
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Номер на картата:',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        _cardNumber!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

            // 4. Save Button
            Center(
              child: GestureDetector(
                onTap: _saveCard,
                child: Container(
                  width: 343,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFF2563EB)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        offset: const Offset(0, 15),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'ДОБАВИ КАРТА',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#DC2626', // Red line color to match our theme
        'Отказ',   // Cancel button text
        true,      // Show flash icon
        ScanMode.BARCODE, // Scan 1D barcodes
      );

      // If the user didn't cancel the scan (-1 is the default cancel value)
      if (barcodeScanRes != '-1') {
        setState(() {
          _cardNumber = barcodeScanRes;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Баркодът е сканиран успешно!')),
          );
        }
      }
    } catch (e) {
      debugPrint('Грешка при сканиране: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Възникна грешка при сканирането.')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // Pick an image from the gallery
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _cardImagePath = image.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Снимката е добавена успешно!')),
          );
        }
      }
    } catch (e) {
      debugPrint('Грешка при избор на снимка: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Възникна грешка при отваряне на галерията.')),
        );
      }
    }
  }

  void _showInputBottomSheet(
    BuildContext context,
    String title,
    String hint,
    bool isNotes,
    Function(String) onSave,
  ) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: isNotes ? 3 : 1,
                  keyboardType:
                      isNotes ? TextInputType.text : TextInputType.number,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      onSave(controller.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Запази',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
    IconData icon,
    String text, {
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 343,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.black,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Save card to the static _myCards list
  void _saveCard() {
    // Validate that card number is provided
    if (_cardNumber == null || _cardNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Моля, добавете номер на картата!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Add card to CardsService
    CardsService.addCard({
      'name': widget.brand['name'],
      'logo': widget.brand['logo'],
      'number': _cardNumber,
      'notes': _additionalNotes,
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Картата е добавена успешно!'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );

    // Pop the details screen
    Navigator.of(context).pop();
    // Pop the brand selection list screen to return to the main grid
    Navigator.of(context).pop();
  }
}
