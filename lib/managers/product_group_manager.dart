import 'package:flutter/material.dart';
import '../models/product_group.dart';

class ProductGroupManager extends ChangeNotifier {
  final List<ProductGroup> _groups = [];

  List<ProductGroup> get groups => List.unmodifiable(_groups);
  
  List<ProductGroup> getSubgroups(String? parentId) => 
    _groups.where((g) => g.parentId == parentId).toList();

  void addGroup(ProductGroup group) {
    // Проверяем уникальность имени в рамках одного уровня
    if (_groups.any((g) => 
        g.name == group.name && 
        g.parentId == group.parentId &&
        g.id != group.id)) {
      throw ArgumentError('Группа "${group.name}" уже существует');
    }
    
    if (group.id.isEmpty) {
      group = group.copyWith(id: UniqueKey().toString());
    }
    
    _groups.add(group);
    notifyListeners();
  }

  void updateGroup(ProductGroup updatedGroup) {
    // Проверяем уникальность имени при обновлении
    if (_groups.any((g) => 
        g.name == updatedGroup.name && 
        g.parentId == updatedGroup.parentId &&
        g.id != updatedGroup.id)) {
      throw ArgumentError('Группа "${updatedGroup.name}" уже существует');
    }

    final index = _groups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
    }
  }

  bool removeGroup(String id) {
    final initialLength = _groups.length;
    _groups.removeWhere((g) => g.id == id);
    final removed = _groups.length != initialLength;
    if (removed) notifyListeners();
    return removed;
  }
}
