import 'cart_item.dart';

class CustomerOrder {
  String id;
  final DateTime date;
  final List<CartItem> items;
  final double total;
  final String paymentMethod;
  bool isReturned; // флаг возврата

  CustomerOrder({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.paymentMethod,
    this.isReturned = false, // по умолчанию не возвращён
  });
}
