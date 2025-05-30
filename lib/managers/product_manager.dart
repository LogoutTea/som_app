import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductManager extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  List<Product> getProductsByGroup(String? groupId) => 
    _products.where((p) => p.groupId == groupId).toList();

  void addProduct(Product product) {
    // Проверка на уникальность артикула
    if (_products.any((p) => p.article == product.article)) {
      throw ArgumentError('Артикул "${product.article}" уже существует');
    }
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    // Проверка на уникальность артикула (исключая текущий товар)
    if (_products.any((p) => p.article == updatedProduct.article && p.id != updatedProduct.id)) {
      throw ArgumentError('Артикул "${updatedProduct.article}" уже используется');
    }
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  bool removeProduct(String id) {
    final initialLength = _products.length;
    _products.removeWhere((p) => p.id == id);
    final removed = _products.length != initialLength;
    if (removed) notifyListeners();
    return removed;
  }

  void fetchProducts() {
    notifyListeners();
  }

  Product? findByArticle(String article) {
    try {
      return _products.firstWhere((p) => p.article == article);
    } catch (_) {
      return null;
    }
  }
}
