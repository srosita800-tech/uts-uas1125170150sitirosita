import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../dashboard/presentation/providers/cart_provider.dart';
import '../../dashboard/presentation/providers/product_provider.dart';
import '../../../../core/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;

    final userName = auth.userModel?['name'] ?? auth.firebaseUser?.displayName ?? 'Pengguna';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catalog Laptop', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              'Halo, $userName!',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        // BAGIAN ACTIONS (ICON KERANJANG) SUDAH DIHAPUS DI SINI
      ),
      body: switch (productProvider.status) {
        ProductStatus.loading || ProductStatus.initial => const Center(
            child: CircularProgressIndicator(),
          ),
        
        ProductStatus.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    productProvider.error ?? 'Gagal terhubung ke server',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => productProvider.fetchProducts(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),

        ProductStatus.loaded => products.isEmpty
          ? const Center(child: Text('Belum ada produk laptop.'))
          : RefreshIndicator(
              onRefresh: () => productProvider.fetchProducts(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, i) {
                  final p = products[i];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.network(
                                p.imageUrl,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Container(
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.laptop, color: Colors.grey),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6), 
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  p.category.toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${p.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await context.read<CartProvider>().addToCart(p.id);
                                      NotificationService.showNotification(
                                        title: "Catalog Laptop",
                                        body: "Yey $userName, ${p.name} sudah masuk keranjang!",
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6)),
                                      padding: EdgeInsets.zero,
                                      elevation: 0,
                                    ),
                                    child: const Text('Beli',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      },
    );
  }
}