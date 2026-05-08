import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/dio_client.dart';
import '../../data/model/cart_model.dart';

class CartProvider extends ChangeNotifier {
  // 1. Variabel utama untuk menyimpan data keranjang
  List<CartModel> _cartItems = [];
  List<CartModel> get cartItems => _cartItems;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 2. Getter untuk menghitung total harga
  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      if (item.product != null) {
        total += (item.product!.price * item.quantity);
      }
    }
    return total;
  }

  // 3. Fungsi Ambil Data (Sangat Penting!)
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await DioClient.instance.get('/cart', 
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      
      final List data = response.data['data'] ?? [];
      _cartItems = data.map((e) => CartModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error Fetch Cart: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Fungsi Tambah ke Keranjang
  Future<void> addToCart(int productId) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      await DioClient.instance.post('/cart/add', 
        data: {'product_id': productId},
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      await fetchCart(); // Refresh data setelah tambah
    } catch (e) {
      debugPrint("Error Add to Cart: $e");
    }
  }

  // 5. Fungsi Kurangi Jumlah (Decrease)
  Future<void> decreaseQuantity(int productId) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      await DioClient.instance.post('/cart/reduce', 
        data: {'product_id': productId},
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      await fetchCart();
    } catch (e) {
      debugPrint("Error Reduce Quantity: $e");
    }
  }

  // 6. Fungsi Hapus Semua (Clear)
  Future<void> clearCartInDatabase() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      await DioClient.instance.delete('/cart', 
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      _cartItems = [];
      notifyListeners();
    } catch (e) {
      debugPrint("Error Clear Cart: $e");
    }
  }
}