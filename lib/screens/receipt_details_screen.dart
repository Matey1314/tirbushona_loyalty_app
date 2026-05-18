import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart'; // Core PDF types
import 'package:pdf/widgets.dart' as pw; // PDF layout widgets
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptDetailsScreen extends StatefulWidget {
  const ReceiptDetailsScreen({super.key});

  @override
  State<ReceiptDetailsScreen> createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends State<ReceiptDetailsScreen> {
  final String _receiptText = '''
M.C ИНЖЕНЕРИНГ ООД
София, жк. "ЛАГЕРА"
ИМЕ МАГАЗИН
АДРЕС МАГАЗИН
ЗДДС № BG130863654

ИМЕ ОПЕРАТОР
УНП: ED303495-0043-0015531
------------------------------------------
Терминал №1             Сист. № 407970
Начало: 09:29              Край: 09:30
------------------------------------------
ИМЕ НА ПРОДУКТА
2x 0,86                           1.72
ИМЕ НА ПРОДУКТА
1x 1,90                           1.90
ИМЕ НА ПРОДУКТА
1x 11,90                         11.90
------------------------------------------
НАЧИН НА ПЛАЩАНЕ       В БРОЙ / КАРТА
ОБЩА СУМА ЕВРО                  17.24
------------------------------------------
ЕЛЕКТРОНЕН ПОРТФЕЙЛ

Клиент:                Матей Пандъров
Карта №:                         1352
Натрупано:                       0.86
Налично:                        14.32
05-03-2026                 09:30:07
------------------------------------------
ФИСКАЛЕН БОН
''';

  // 1. Core PDF Generator
  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Receipt roll width format
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Text(
              _receiptText,
              style: pw.TextStyle(
                font: pw.Font.courier(),
                fontSize: 11,
                lineSpacing: 2,
              ),
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  // 2. Clear Download Action
  Future<void> _downloadPdf() async {
    try {
      final bytes = await _generatePdf();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/khasov_bon.pdf');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Файлът е запазен успешно в: ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Грешка при сваляне: $e');
    }
  }

  // 3. Clear Share Action
  Future<void> _sharePdf() async {
    try {
      final bytes = await _generatePdf();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/khasov_bon.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Моят електронен касов бон от Мирбушона',
      );
    } catch (e) {
      _showErrorSnackBar('Грешка при споделяне: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      appBar: AppBar(
        title: const Text('Електронен касов бон'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Top Active Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _downloadPdf,
                  icon: const Icon(Icons.file_download, color: Colors.white),
                  label: const Text('Свали PDF', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _sharePdf,
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text('Сподели PDF', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Plain White Receipt Layout
            Center(
              child: Container(
                width: 335,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 50,
                        errorBuilder: (c, e, s) => const Text(
                          'МИРБУШОНА',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Merchant Metadata (Center-aligned)
                    const Center(
                      child: Text(
                        'М.С ИНЖЕНЕРИНГ ООД',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'София, жк. "ЛАГЕРА"',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'ИМЕ МАГАЗИН',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'АДРЕС МАГАЗИН',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'ЗДДС № BG130863654',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Divider 1
                    const Center(
                      child: Text(
                        '------------------------------------------',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Operator & Terminal Info (Left-aligned)
                    const Text(
                      'ИМЕ ОПЕРАТОР',
                      style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'УНП: ED303495-0043-0015531',
                      style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 8),

                    // Session Metrics (Space-between)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Терминал    №1',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          'Сист. № 407970',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Начало: 09:29',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          'Край: 09:30',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Divider 2
                    const Center(
                      child: Text(
                        '------------------------------------------',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Product 1: БАТЕРИЯ АЛКАЛНА АА
                    const Text(
                      'БАТЕРИЯ АЛКАЛНА АА',
                      style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '2x 0,86',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          '1.72',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Product 2: ГУМЕНА ТОПКА СКОК
                    const Text(
                      'ГУМЕНА ТОПКА СКОК',
                      style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '1x 1,90',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          '1.90',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Product 3: МАРКЕРИ КОМПЛЕКТ
                    const Text(
                      'МАРКЕРИ КОМПЛЕКТ',
                      style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '1x 11,90',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          '11.90',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Divider 3
                    const Center(
                      child: Text(
                        '------------------------------------------',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Payment Method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'НАЧИН НА ПЛАЩАНЕ',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'В БРОЙ / КАРТА',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Total Amount (Large & Bold)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'ОБЩА СУМА ЕВРО',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.black,
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '17.24',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.black,
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Upper Divider
                    const Center(
                      child: Text(
                        '------------------------------------------',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Wallet Heading
                    const Center(
                      child: Text(
                        'ЕЛЕКТРОНЕН ПОРТФЕЙЛ',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.black,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Wallet Metrics (Space-between Rows)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Клиент:',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          'Матей Пандъров',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Карта №:',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          '1352',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Натрупано:',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          '0.86',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Налично:',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          '14.32',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '05-03-2026',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        Text(
                          '09:30:07',
                          style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Lower Divider
                    const Center(
                      child: Text(
                        '------------------------------------------',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Centered QR Code Block
                    Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        child: Image.asset(
                          'assets/images/qr_code.png',
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.qr_code_2, size: 80, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Centered Fiscal Footer Message
                    const Center(
                      child: Text(
                        'ФИСКАЛЕН БОН',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.black,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
