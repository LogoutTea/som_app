import 'package:flutter/material.dart';
import '../models/partner.dart';

class PartnerManager extends ChangeNotifier {
  final List<Partner> _partners = [];

  List<Partner> get partners => List.unmodifiable(_partners);

  void addPartner(Partner partner) {
    _partners.add(partner);
    notifyListeners();
  }

  void updatePartner(Partner updated) {
    final index = _partners.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _partners[index] = updated;
      notifyListeners();
    }
  }

  void removePartner(String id) {
    _partners.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
