import 'package:flutter/material.dart';

class CashManager extends ChangeNotifier {
  double _balance = 0.0;

  double get balance => _balance;

  void addCash(double amount) {
    _balance += amount;
    notifyListeners();
  }

  void withdrawCash(double amount) {
    if (amount <= _balance) {
      _balance -= amount;
      notifyListeners();
    }
  }

  // Новый метод для вычитания (можно использовать без проверки баланса)
  void removeCash(double amount) {
    _balance -= amount;
    notifyListeners();
  }
}
