import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/order_manager.dart';
import '../models/customer_order.dart';
import '../managers/cash_manager.dart';

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  CustomerOrder? selectedCheck;

  void _selectCheck(BuildContext context) async {
    final orderManager = Provider.of<OrderManager>(context, listen: false);
    final checks = orderManager.orders
        .where((o) => o.id.startsWith('CHECK') && !o.isReturned)
        .toList();

    if (checks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет чеков для возврата')),
      );
      return;
    }

    final check = await showDialog<CustomerOrder>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Выберите чек'),
        children: checks.map((o) => SimpleDialogOption(
          child: Text('Чек #${o.id} (${o.paymentMethod})'),
          onPressed: () => Navigator.pop(ctx, o),
        )).toList(),
      ),
    );

    if (check != null) {
      setState(() {
        selectedCheck = check;
      });
    }
  }

void _processReturn(BuildContext context) {
  if (selectedCheck == null) return;

  final orderManager = Provider.of<OrderManager>(context, listen: false);
  final cashManager = Provider.of<CashManager>(context, listen: false);
  
  if (selectedCheck!.paymentMethod == 'Наличные') {
    final currentBalance = cashManager.balance;
    final refundAmount = selectedCheck!.total;
    
    if (currentBalance < refundAmount) {
      final shortage = refundAmount - currentBalance;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Недостаточно наличных. Не хватает: ${shortage.toStringAsFixed(2)} руб.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Отменяем возврат
    }
  }

  orderManager.markOrderAsReturned(selectedCheck!.id);

  if (selectedCheck!.paymentMethod == 'Наличные') {
    cashManager.removeCash(selectedCheck!.total);
  }

  setState(() {
    selectedCheck = null;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Возврат по чеку оформлен')),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Возвраты')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _selectCheck(context),
              child: const Text('Возврат по чеку'),
            ),
            if (selectedCheck != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Чек #${selectedCheck!.id} (${selectedCheck!.paymentMethod})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedCheck!.items.length,
                        itemBuilder: (ctx, i) {
                          final item = selectedCheck!.items[i];
                          return ListTile(
                            title: Text(item.product.name),
                            subtitle: Text('${item.quantity} x ${item.product.price} руб.'),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _processReturn(context),
                      child: const Text('Подтвердить возврат'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
