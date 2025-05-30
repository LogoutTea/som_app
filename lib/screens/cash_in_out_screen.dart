import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../managers/cash_manager.dart';

class CashInOutScreen extends StatefulWidget {
  const CashInOutScreen({super.key});

  @override
  State<CashInOutScreen> createState() => _CashInOutScreenState();
}

class _CashInOutScreenState extends State<CashInOutScreen> {
  void _showAmountDialog(bool isDeposit) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isDeposit ? 'Внесение денег' : 'Выплата денег'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*'))],
          decoration: const InputDecoration(
            labelText: 'Сумма',
            hintText: 'Введите сумму',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Подтвердить'),
            onPressed: () {
              final value = double.tryParse(controller.text);
              final cashManager = Provider.of<CashManager>(context, listen: false);

              if (value == null || value <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите корректную сумму')),
                );
                return;
              }

              if (!isDeposit && value > cashManager.balance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Недостаточно средств для выплаты'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(ctx).pop();
              if (isDeposit) {
                cashManager.addCash(value);
              } else {
                cashManager.withdrawCash(value);
              }
            },
          ),
        ],
      ),
    );
  }

  void _withdrawAllCash() {
    final cashManager = Provider.of<CashManager>(context, listen: false);
    final amount = cashManager.balance;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('В кассе нет денег для изъятия')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Изъять всю сумму'),
        content: Text('Вы уверены, что хотите изъять всю сумму: ${amount.toStringAsFixed(2)} руб.?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              cashManager.withdrawCash(amount);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Изъято ${amount.toStringAsFixed(2)} руб.')),
              );
            },
            child: const Text('Изъять'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cashManager = Provider.of<CashManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Внесение/Выплата')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Текущий баланс: ${cashManager.balance.toStringAsFixed(2)} руб.',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              label: const Text('Внесение денег'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () => _showAmountDialog(true),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              label: const Text('Выплата денег'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () => _showAmountDialog(false),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.money_off, color: Colors.orange),
              label: const Text('Изъять всю сумму'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                foregroundColor: const Color.fromARGB(255, 79, 56, 163),
              ),
              onPressed: _withdrawAllCash,
            ),
          ],
        ),
      ),
    );
  }
}
