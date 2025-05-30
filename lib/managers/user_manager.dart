import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

class UserManager extends ChangeNotifier {
  final List<User> _users = [
    User(
      username: 'Порываев Е.М.',
      password: _hashPassword('123'),
      inn: '662500223980',
      role: UserRole.admin,
    ),
    User(
      username: 'User',
      password: _hashPassword('123'),
      inn: '1234567890',
      role: UserRole.cashier,
    ),
  ];

  User? _currentUser;

  static String _hashPassword(String password) => 
    sha256.convert(utf8.encode(password)).toString();

  List<User> get users => List.unmodifiable(_users);
  User? get currentUser => _currentUser;

  bool login(String username, String password) {
    final hashed = _hashPassword(password);
    try {
      _currentUser = _users.firstWhere(
        (u) => u.username == username && u.password == hashed
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void addUser(String username, String password, String inn) {
    if (_users.any((u) => u.username == username)) {
      throw ArgumentError('Имя пользователя занято');
    }
    _users.add(User(
      username: username,
      password: _hashPassword(password),
      inn: inn,
      role: UserRole.cashier,
    ));
    notifyListeners();
  }

  bool deleteUser(String username) {
    final initialCount = _users.length;
    _users.removeWhere((u) => u.username == username);
    final removed = _users.length != initialCount;
    if (removed) notifyListeners();
    return removed;
  }
}
