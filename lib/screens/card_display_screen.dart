import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CardDisplayScreen extends StatefulWidget {
  final Map<String, dynamic> card;
  const CardDisplayScreen({super.key, required this.card});

  @override
  State<CardDisplayScreen> createState() => _CardDisplayScreenState();
}

class _CardDisplayScreenState extends State<CardDisplayScreen> {
  Map<String, dynamic>? _templateData;
  bool _isLoading = true;
  bool _isIncrementingUsage = false;

  @override
  void initState() {
    super.initState();
    _loadTemplate();
    _incrementUsage(); // ТОВА Е МАГИЯТА – добави този ред тук!
  }

  Future<void> _loadTemplate() async {
    try {
      final data = await Supabase.instance.client
          .from('card_templates')
          .select()
          .eq('id', widget.card['template_id'])
          .single();
      if (mounted) setState(() => _templateData = data);
    } catch (e) {
      debugPrint('Грешка при зареждане на шаблона: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCard() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Изтриване на карта', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Сигурни ли сте, че искате да изтриете тази карта?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отказ')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Изтрий')),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.from('wallet_cards').delete().eq('id', widget.card['id']);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _incrementUsage() async {
    try {
      // Взимаме текущия брой и добавяме 1
      final currentCount = (widget.card['usage_count'] ?? 0) as int;
      debugPrint("Опитвам се да обновя карта с ID: ${widget.card['id']} и текущо броене: $currentCount");
      await Supabase.instance.client
          .from('wallet_cards')
          .update({'usage_count': currentCount + 1})
          .eq('id', widget.card['id']);

      debugPrint("Успешно увеличен брояч за карта: ${widget.card['id']}");
    } catch (e) {
      debugPrint("Грешка при брояча: $e");
    }
  }

  void _showBarcodeOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.75,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: widget.card['card_number'] ?? '000000000000',
                          width: double.infinity,
                          height: 300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Затвори')),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(widget.card['store_name'] ?? 'Карта'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)), onPressed: _deleteCard),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Column(
              children: [
                // Стария дизайн на плочката
                Container(
                  width: 343,
                  height: 215,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator()
                      : Image.network(_templateData?['logo_url'] ?? '', errorBuilder: (_,__,___) => const Icon(Icons.credit_card, size: 60)),
                  ),
                ),
                const SizedBox(height: 40),
                // Стария дизайн на бутона
                GestureDetector(
                  onTap: () async {
                    if (_isIncrementingUsage) return;
                    setState(() => _isIncrementingUsage = true);
                    try {
                      await _incrementUsage();
                    } catch (e) {
                      debugPrint('Грешка при увеличаване на usage_count: $e');
                    } finally {
                      if (mounted) setState(() => _isIncrementingUsage = false);
                    }
                    if (context.mounted) {
                      _showBarcodeOverlay(context);
                    }
                  },
                  child: Opacity(
                    opacity: _isIncrementingUsage ? 0.7 : 1,
                    child: Container(
                    width: 332,
                    height: 49,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFF2563EB)]),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: _isIncrementingUsage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('СКАНИРАЙ КАРТА', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  ),
                ),
                const SizedBox(height: 30),
                // Стария дизайн на бележките
                if (widget.card['notes'] != null && widget.card['notes'].toString().isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Бележки', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(widget.card['notes'].toString(), style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}