import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart'; // Добавен импорт за началния екран

class CardOnboardingScreen extends StatelessWidget {
  const CardOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 100, errorBuilder: (c, e, s) => const Icon(Icons.loyalty, size: 80, color: Colors.blue)),
              const SizedBox(height: 40),
              const Text('Добре дошли в М.С. Инженеринг!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Изберете как искате да ползвате програмата.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => _handleGenerateVirtualCard(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('ИСКАМ КАРТА', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => _showConnectCardDialog(context),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('ИМАМ КАРТА', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGenerateVirtualCard(BuildContext context) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    final response = await Supabase.instance.client
        .from('profiles')
        .select('physical_card_number')
        .like('physical_card_number', '200%') 
        .order('physical_card_number', ascending: false)
        .limit(1)
        .maybeSingle();

    String nextNumber;
    if (response != null && response['physical_card_number'] != null) {
      int lastNum = int.parse(response['physical_card_number'].toString());
      nextNumber = (lastNum + 1).toString();
    } else {
      nextNumber = '20010001';
    }

    await Supabase.instance.client.from('profiles').update({
      'physical_card_number': nextNumber,
      'logistic_card_number': '0000'
    }).eq('id', userId);
    
    if (context.mounted) {
      Navigator.pop(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _showConnectCardDialog(BuildContext context) {
    final physController = TextEditingController();
    final logController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Свързване на карта'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: physController, decoration: const InputDecoration(labelText: 'Физически номер (8 цифри)'), keyboardType: TextInputType.number),
            TextField(controller: logController, decoration: const InputDecoration(labelText: 'Код от касиера (4 цифри)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отказ')),
          ElevatedButton(
            onPressed: () => _verifyAndConnectCard(context, physController.text.trim(), logController.text.trim()),
            child: const Text('СВЪРЖИ'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyAndConnectCard(BuildContext context, String phys, String log) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final tunnelUrl = 'https://blast-drool-duplicity.ngrok-free.dev';
    
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final response = await http.get(
        Uri.parse('$tunnelUrl/verify?phys=$phys&log=$log'),
        headers: {
          "ngrok-skip-browser-warning": "69420"
        },
      );

      if (response.statusCode == 200) {
        await Supabase.instance.client.from('profiles').update({
          'physical_card_number': phys,
          'logistic_card_number': log 
        }).eq('id', userId);

        if (context.mounted) {
          Navigator.pop(context); // Затваря Loading
          Navigator.pop(context); // Затваря Диалога
          
          // Поправка: Директно отваряне на HomeScreen и изчистване на стека
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Грешен номер или код! Провери на касата.'), 
            backgroundColor: Colors.red
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Касата не отговаря. Провери връзката!'), 
          backgroundColor: Colors.orange
        ));
      }
    }
  }
}