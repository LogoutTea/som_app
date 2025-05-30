import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'managers/user_manager.dart';
import 'managers/sales_manager.dart';
import 'screens/auth_screen.dart';
import 'managers/order_manager.dart';
import 'managers/cash_manager.dart';
import 'managers/kkm_manager.dart';
import 'managers/product_manager.dart';
import 'managers/product_group_manager.dart';
import 'models/partner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PartnerAdapter());
  await Hive.openBox<Partner>('partners');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserManager>(create: (_) => UserManager()),
        ChangeNotifierProvider<SalesManager>(create: (_) => SalesManager()),
        ChangeNotifierProvider<OrderManager>(create: (_) => OrderManager()),
        ChangeNotifierProvider<CashManager>(create: (_) => CashManager()),
        ChangeNotifierProvider<KKMManager>(create: (_) => KKMManager()),
        ChangeNotifierProvider<ProductManager>(create: (_) => ProductManager()),
        ChangeNotifierProvider<ProductGroupManager>(create: (_) => ProductGroupManager()),
      ],
      child: MaterialApp(
        title: 'Сомчик',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthScreen(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', 'RU'),
          Locale('en', 'US'),
        ],
      ),
    );
  }
}
