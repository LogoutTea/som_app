// lib/screens/support_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _callSupport() async {
    final Uri phoneNumber = Uri.parse('tel:89655145553');
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      throw 'Не удалось выполнить вызов';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Техническая поддержка')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.phone, size: 80, color: Colors.blue),
                onPressed: _callSupport,
              ),
              const SizedBox(height: 24),
              const Text(
                'Нажмите на иконку телефона,\nчтобы позвонить в поддержку, \nПорываев Евгений Михайлович',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _callSupport,
                child: const Text(
                  '8 (965) 514-55-53',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
