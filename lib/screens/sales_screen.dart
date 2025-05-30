import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/product_manager.dart';
import '../managers/order_manager.dart';
import '../managers/cash_manager.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/customer_order.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}


class _SalesScreenState extends State<SalesScreen> {
  final List<CartItem> cart = [];

  void _showAddProductDialog(BuildContext context, List<Product> products) async {
    final result = await showDialog<CartItem>(
      context: context,
      builder: (ctx) => _AddProductDialog(products: products),
    );
    if (result != null) {
      setState(() {
        final index = cart.indexWhere((item) => item.product.id == result.product.id);
        if (index >= 0) {
          cart[index].quantity += result.quantity;
        } else {
          cart.add(result);
        }
      });
    }
  }

  double get total => cart.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

  void _placeOrder(BuildContext context, String paymentMethod) {
    if (cart.isEmpty) return;

    final orderManager = Provider.of<OrderManager>(context, listen: false);

    final order = CustomerOrder(
      id: '', // id присвоится автоматически в addOrder
      date: DateTime.now(),
      items: cart.map((e) => CartItem(product: e.product, quantity: e.quantity)).toList(),
      total: total,
      paymentMethod: paymentMethod,
    );
    orderManager.addOrder(order, isCheck: true);

    if (paymentMethod == 'Наличные') {
      Provider.of<CashManager>(context, listen: false).addCash(total);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Оплата: $paymentMethod'),
        content: Text('Чек №${order.id}\nЗаказ оформлен!\nСумма: ${total.toStringAsFixed(2)} руб.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => cart.clear());
              Navigator.of(ctx).pop();
              // Не удаляем заказ, чтобы он был доступен для возврата!
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCustomerOrdersDialog(BuildContext context) {
    final orderManager = Provider.of<OrderManager>(context, listen: false);
    final orders = orderManager.orders;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выберите заказ'),
        content: SizedBox(
          width: double.maxFinite,
          child: orders.isEmpty
              ? const Text('Нет доступных заказов')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: orders.length,
                  itemBuilder: (_, index) {
                    final order = orders[index];
                    return ListTile(
                      title: Text('Заказ #${order.id}'),
                      subtitle: Text(
                        '${order.date.day}.${order.date.month}.${order.date.year} - '
                        '${order.total.toStringAsFixed(2)} руб.',
                      ),
                      onTap: () {
                        setState(() {
                          cart.clear();
                          for (final item in order.items) {
                            final existingIndex = cart.indexWhere(
                              (c) => c.product.id == item.product.id);
                            if (existingIndex >= 0) {
                              cart[existingIndex].quantity += item.quantity;
                            } else {
                              cart.add(CartItem(
                                product: item.product, 
                                quantity: item.quantity));
                            }
                          }
                        });
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productManager = Provider.of<ProductManager>(context);
    final products = productManager.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продажи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'История заказов',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Заказ покупателя'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(220, 48),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _showCustomerOrdersDialog(context),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Добавить товар'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(220, 48),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _showAddProductDialog(context, products),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: cart.isEmpty
                  ? const Center(child: Text('Добавьте заказ или товар')) //гл.экран с выводом сообщения
                  : ListView.separated(
                      itemCount: cart.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (ctx, i) {
                        final item = cart[i];
                        return ListTile(
                          title: Text(item.product.name),
                          subtitle: Text('${item.product.price} руб. x ${item.quantity}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => cart.removeAt(i));
                            },
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Итого: ${total.toStringAsFixed(2)} руб.',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (cart.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Оплата наличными'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _placeOrder(context, 'Наличные'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Оплата безналичными'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _placeOrder(context, 'Безналичные'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Оплата по СБП'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _placeOrder(context, 'СБП'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  final List<Product> products;
  const _AddProductDialog({required this.products});

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  Product? selectedProduct;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить товар'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Product>(
            value: selectedProduct,
            items: widget.products.map((product) {
              return DropdownMenuItem<Product>(
                value: product,
                child: Text('${product.name} (${product.price} руб.)'),
              );
            }).toList(),
            onChanged: (product) {
              setState(() {
                selectedProduct = product;
                quantity = 1;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Товар',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (selectedProduct != null)
            Row(
              children: [
                const Text('Количество:'),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: quantity > 1
                      ? () => setState(() => quantity--)
                      : null,
                ),
                Text('$quantity', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: selectedProduct == null
              ? null
              : () {
                  Navigator.of(context).pop(
                    CartItem(product: selectedProduct!, quantity: quantity),
                  );
                },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderManager>(context).orders;

    return Scaffold(
      appBar: AppBar(title: const Text('История заказов')),
      body: orders.isEmpty
          ? const Center(child: Text('Нет завершенных заказов'))
          : ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final order = orders[i];
                return ListTile(
                  title: Text(
                    'Заказ #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Дата: ${order.date.toLocal()}'),
                      Text('Оплата: ${order.paymentMethod}'),
                      Text('Сумма: ${order.total.toStringAsFixed(2)} руб.'),
                      const SizedBox(height: 4),
                      const Text('Товары:'),
                      ...order.items.map((item) => Text(
                          '- ${item.product.name} x${item.quantity} (${item.product.price} руб.)')),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
