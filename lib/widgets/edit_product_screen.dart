import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/product_group.dart';
import '../managers/product_manager.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  final List<ProductGroup> groups;

  const EditProductScreen({super.key, required this.product, required this.groups});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController articleController;
  late TextEditingController priceController;
  late TextEditingController ean13Controller;
  late TextEditingController quantityController;
  String type = 'Товар';
  String? groupId;
  bool isMarked = false;
  String? markedCategory;
  String country = 'Россия';
  double nds = 20.0;

  final List<String> countryList = [
    'Россия',
    'Китай',
    'Турция',
    'Германия',
    'Италия',
    'США',
    'Корея',
    'Япония',
  ];

  final List<double> ndsList = [
    0.0,
    10.0,
    20.0,
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    articleController = TextEditingController(text: widget.product.article);
    priceController = TextEditingController(text: widget.product.price.toString());
    ean13Controller = TextEditingController(text: widget.product.ean13 ?? '');
    quantityController = TextEditingController(text: widget.product.quantity?.toString() ?? '');
    type = widget.product.type;
    groupId = widget.product.groupId;
    isMarked = widget.product.isMarked;
    markedCategory = widget.product.markedCategory;
    country = widget.product.country.isNotEmpty ? widget.product.country : 'Россия';
    nds = widget.product.nds;
  }

  @override
  void dispose() {
    nameController.dispose();
    articleController.dispose();
    priceController.dispose();
    ean13Controller.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveProduct(BuildContext context) {
    final name = nameController.text.trim();
    final article = articleController.text.trim();
    final priceText = priceController.text.trim();
    final ean13 = ean13Controller.text.trim();
    final quantityText = quantityController.text.trim();

    // Валидация обязательных полей
    if (name.isEmpty || article.isEmpty || priceText.isEmpty) {
      _showError('Заполните обязательные поля (помечены *)');
      return;
    }

    // Валидация цены
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      _showError('Введите корректную цену (положительное число)');
      return;
    }

    // Валидация штрих-кода (если заполнен)
    if (ean13.isNotEmpty && (ean13.length != 12 && ean13.length != 13 || !RegExp(r'^\d+$').hasMatch(ean13))) {
      _showError('Штрих-код должен содержать 12 или 13 цифр');
      return;
    }

    // Валидация количества (если заполнено)
    int? quantity;
    if (quantityText.isNotEmpty) {
      quantity = int.tryParse(quantityText);
      if (quantity == null || quantity < 0) {
        _showError('Количество должно быть положительным числом');
        return;
      }
    }

    // Валидация маркированного товара
    if (isMarked && (markedCategory == null || markedCategory!.isEmpty)) {
      _showError('Выберите категорию маркированного товара');
      return;
    }

    final String productId = widget.product.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : widget.product.id;

    final updatedProduct = Product(
      id: productId,
      name: name,
      article: article,
      price: price,
      ean13: ean13.isEmpty ? null : ean13,
      quantity: quantity,
      type: type,
      groupId: groupId,
      isMarked: isMarked,
      markedCategory: isMarked ? markedCategory : null,
      country: country,
      nds: nds,
    );

    try {
      if (widget.product.id.isEmpty) {
        // Новый товар
        context.read<ProductManager>().addProduct(updatedProduct);
      } else {
        // Обновление
        context.read<ProductManager>().updateProduct(updatedProduct);
      }
      Navigator.of(context).pop(updatedProduct);
    } catch (e) {
      _showError(
        e.toString().replaceAll('ArgumentError:', '').replaceAll('Exception:', '').trim(),
      );
    }
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text('Вы уверены, что хотите удалить "${widget.product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      context.read<ProductManager>().removeProduct(widget.product.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.id.isEmpty ? 'Новый товар' : 'Редактировать товар'),
        actions: [
          if (widget.product.id.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String?>(
                value: groupId,
                decoration: const InputDecoration(labelText: 'Группа (необязательно)'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Без группы'),
                  ),
                  ...widget.groups
                      .map((g) => DropdownMenuItem<String?>(
                            value: g.id,
                            child: Text(g.name),
                          ))
                ],
                onChanged: (val) => setState(() => groupId = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Тип'),
                items: ['Товар', 'Услуга']
                    .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => type = val);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: country,
                decoration: const InputDecoration(labelText: 'Страна производства'),
                items: countryList
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => country = val ?? 'Россия'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: nds,
                decoration: const InputDecoration(labelText: 'Ставка НДС'),
                items: ndsList
                    .map((n) => DropdownMenuItem(
                          value: n,
                          child: Text(n == 0.0 ? '0% (без НДС)' : '${n.toStringAsFixed(0)}%'),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => nds = val ?? 20.0),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: isMarked,
                onChanged: (val) {
                  setState(() {
                    isMarked = val ?? false;
                    if (!isMarked) markedCategory = null;
                  });
                },
                title: const Text('Маркированный товар'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (isMarked)
                DropdownButtonFormField<String>(
                  value: markedCategory,
                  decoration: const InputDecoration(labelText: 'Категория маркировки'),
                  items: const [
                    DropdownMenuItem(value: 'Текстиль', child: Text('Текстиль')),
                    DropdownMenuItem(value: 'Строительные материалы', child: Text('Строительные материалы')),
                  ],
                  onChanged: (val) => setState(() => markedCategory = val),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название*',
                  hintText: 'Обязательное поле',
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: articleController,
                decoration: const InputDecoration(
                  labelText: 'Артикул*',
                  hintText: 'Обязательное поле',
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Цена*',
                  hintText: 'Обязательное поле',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ean13Controller,
                decoration: const InputDecoration(
                  labelText: 'Штрих-код',
                  hintText: 'Необязательное поле',
                ),
                keyboardType: TextInputType.number,
                maxLength: 13,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Количество',
                  hintText: 'Необязательное поле',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Сохранить товар'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => _saveProduct(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
