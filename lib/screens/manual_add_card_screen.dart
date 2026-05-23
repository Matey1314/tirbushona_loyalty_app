import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManualAddCardScreen extends StatefulWidget {
  const ManualAddCardScreen({super.key});

  @override
  State<ManualAddCardScreen> createState() => _ManualAddCardScreenState();
}

class _ManualAddCardScreenState extends State<ManualAddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Записваме в базата, като template_id остава null
      await Supabase.instance.client.from('wallet_cards').insert({
        'user_id': userId,
        'store_name': _nameController.text.trim(),
        'card_number': _numberController.text.trim(),
        'notes': _notesController.text.trim(),
      });

      if (mounted) {
        // Връщаме се чак до началния екран, за да видим новата карта
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint('Грешка при ръчно добавяне: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Възникна грешка при запазването.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Ръчно добавяне'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Име на търговския обект *'),
              _buildTextField(
                controller: _nameController,
                hint: 'напр. Кварталния магазин',
                validator: (val) => val == null || val.isEmpty ? 'Моля, въведете име' : null,
              ),
              const SizedBox(height: 20),
              
              _buildLabel('Номер на картата / Баркод *'),
              _buildTextField(
                controller: _numberController,
                hint: 'Въведете номера под баркода',
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Моля, въведете номер' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('Бележки (опционално)'),
              _buildTextField(
                controller: _notesController,
                hint: 'напр. Картата е на името на Иван',
                maxLines: 3,
              ),
              const SizedBox(height: 40),

              // Бутон за запазване
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ЗАПАЗИ КАРТАТА', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}