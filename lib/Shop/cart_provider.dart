// cart_provider.dart
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addItem(Map<String, dynamic> item) {
    // Cek apakah item sudah ada di keranjang, jika ya, tambahkan kuantitasnya
    final existingIndex = _cartItems.indexWhere((cartItem) => cartItem['id'] == item['id']);
    if (existingIndex != -1) {
      _cartItems[existingIndex]['quantity'] += item['quantity'] ?? 1;
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int productId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      _cartItems[index]['quantity'] = newQuantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}