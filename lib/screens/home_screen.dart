import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'products_screen.dart';
import 'cash_in_out_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'returns_screen.dart';
import 'sales_screen.dart';
import '../managers/user_manager.dart';
import '../managers/kkm_manager.dart';
import 'auth_screen.dart';
import 'support_screen.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Проверка на доступность ККТ перед входом в продажи
  Future<void> enterSalesScreen() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final kkmManager = Provider.of<KKMManager>(context, listen: false);
    bool available = false;
    try {
      for (var device in kkmManager.devices) {
        if (await kkmManager.checkDeviceOnline(device.ip, device.port)) {
          available = true;
          break;
        }
      }
    } finally {
      if (mounted) Navigator.of(context).pop();
    }

    if (!mounted) return;

    if (available) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SalesScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сервер не доступен')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userManager = Provider.of<UserManager>(context);
    final userRole = userManager.currentUser?.role;
    return Scaffold(
      appBar: AppBar(
        title: Text(userManager.currentUser?.username ?? "Гость"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () {
              userManager.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // ЗДЕСЬ МЕНЯЕМ ВЫЗОВ ДЛЯ ПРОДАЖ:
          _buildMenuButton('Продажи', Icons.point_of_sale, () => enterSalesScreen()),
          _buildMenuButton('Возвраты', Icons.assignment_return, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReturnsScreen()))),
          _buildMenuButton('Товары', Icons.inventory, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()))),
          _buildMenuButton('Внесение или выплата', Icons.account_balance_wallet, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CashInOutScreen()))),
          _buildMenuButton('Отчеты', Icons.analytics, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
          _buildMenuButton('Техническая поддержка', Icons.support_agent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()))),
          if (userRole == UserRole.admin)
          _buildMenuButton('Настройки', Icons.settings, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))), // Видимость только для Админа
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(icon, size: 40),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: onPressed,
    );
  }
}
