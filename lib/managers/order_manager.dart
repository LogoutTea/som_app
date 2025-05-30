import 'package:flutter/material.dart';
import '../models/customer_order.dart';

class OrderManager extends ChangeNotifier { // Наследуемся от ChangeNotifier
  final List<CustomerOrder> _orders = [];
  int _lastCheckNumber = 0;

  List<CustomerOrder> get orders => _orders;

  void addOrder(CustomerOrder order, {bool isCheck = true}) {
    if (isCheck) {
      _lastCheckNumber += 1;
      order.id = 'CHECK$_lastCheckNumber';
    }
    _orders.add(order);
    notifyListeners();
  }

  // Добавляем метод для пометки заказа как возвращённого
  void markOrderAsReturned(String orderId) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    order.isReturned = true;
    notifyListeners(); // Уведомляем об изменении
  }
}
