import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dashboard/presentation/providers/cart_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan watch agar data sinkron
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final cartItems = cartProvider.cartItems;
    final userName = authProvider.userModel?['name'] ?? 'Shandy';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Bagian Daftar Barang
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text('${item.quantity}x'),
                  ),
                  title: Text(item.product?.name ?? 'Produk', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rp ${item.product?.price.toStringAsFixed(0)}'),
                  trailing: Text(
                    'Rp ${(item.quantity * (item.product?.price ?? 0)).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          
          // Bagian Total & Tombol Bayar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Biaya', style: TextStyle(fontSize: 18)),
                    Text('Rp ${cartProvider.totalPrice.toStringAsFixed(0)}', 
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty ? null : () async {
                      // Ini akan memanggil endpoint DELETE /cart di Golang
                      await context.read<CartProvider>().clearCartInDatabase();

                      // 2. Munculkan Notifikasi Pop-up (Kayak WA)
                      NotificationService.showNotification(
                        title: "Catalog Laptop",
                        body: "Yey $userName, Pembayaran Berhasil! Barang sedang disiapkan toko ya!",
                      );

                      // Semua halaman di belakang (Cart/Checkout) akan dihapus dari memori
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Warna sukses
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'BAYAR SEKARANG',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}