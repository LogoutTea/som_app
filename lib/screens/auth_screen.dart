import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/user_manager.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String? selectedUser;
  final passwordController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final userManager = Provider.of<UserManager>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedUser,
                  hint: const Text('Выберите пользователя'),
                  items: userManager.users
                      .map((u) => DropdownMenuItem(
                            value: u.username,
                            child: Text(u.username),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUser = value;
                      errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Пароль (только цифры)'),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _login(context),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: const Text('Войти'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _showCreateUserDialog(context),
                  child: const Text('Создать пользователя'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    final userManager = Provider.of<UserManager>(context, listen: false);
    final password = passwordController.text;
    if (selectedUser == null || password.isEmpty) {
      setState(() {
        errorMessage = 'Заполните все поля';
      });
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(password)) {
      setState(() {
        errorMessage = 'Пароль должен содержать только цифры';
      });
      return;
    }
    final success = userManager.login(selectedUser!, password);
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        errorMessage = 'Неверный пароль';
      });
    }
  }

  void _showCreateUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final innController = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Создать пользователя'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Имя пользователя'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Пароль (только цифры)'),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              TextField(
                controller: innController,
                decoration: const InputDecoration(labelText: 'ИНН'),
                keyboardType: TextInputType.number,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final username = usernameController.text.trim();
                final password = passwordController.text.trim();
                final inn = innController.text.trim();
                if (username.isEmpty || password.isEmpty || inn.isEmpty) {
                  setState(() => error = 'Заполните все поля');
                  return;
                }
                if (!RegExp(r'^\d+$').hasMatch(password)) {
                  setState(() => error = 'Пароль должен содержать только цифры');
                  return;
                }
                Provider.of<UserManager>(context, listen: false).addUser(
                  username,
                  password,
                  inn,
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Пользователь "$username" создан')),
                );
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }
}
