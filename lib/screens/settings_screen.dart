import 'package:flutter/material.dart';
import 'equipment_screen.dart';
import 'partners_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          ListTile(
  leading: const Icon(Icons.devices),
  title: const Text('Оборудование'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EquipmentScreen()),
    );
  },
),     
          ListTile(
            leading: const Icon(Icons.account_tree),
            title: const Text('Контрагенты'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PartnersScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}