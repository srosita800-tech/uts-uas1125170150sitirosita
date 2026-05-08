import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../dashboard/data/model/product_model.dart';
import '../../../dashboard/presentation/providers/product_provider.dart';
import '../sheet/product_form_sheet.dart';

class AdminProductPage extends StatefulWidget {
  const AdminProductPage({super.key});

  @override
  State<AdminProductPage> createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  @override
  void initState() {
    super.initState();
    // ignore: use_build_context_synchronously
    Future.microtask(() => context.read<ProductProvider>().fetchProducts());
  }

  void _showProductForm(BuildContext context, {ProductModel? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => ProductFormSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, size: 28),
            onPressed: () => _showProductForm(context), 
          )
        ],
      ),
      body: productProvider.status == ProductStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('Belum ada produk untuk dikelola.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p.imageUrl,
                              width: 60, height: 60, fit: BoxFit.cover,
                              // ignore: unnecessary_underscores
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LABEL KATEGORI (Badge)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.redAccent
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${p.price.toStringAsFixed(0)} • Stok: ${p.stock}',
                                style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              // DESKRIPSI
                              Text(
                                p.description ?? "Tidak ada deskripsi",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, color: Colors.blue),
                                onPressed: () => _showProductForm(context, product: p), 
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                onPressed: () => _confirmDelete(context, p.id, p.name),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // DIALOG HAPUS Sekarang panggil deleteProduct di Provider
  void _confirmDelete(BuildContext context, int id, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Apakah kamu yakin ingin menghapus "$productName" dari Catalog LaptopProduction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              final success = await context.read<ProductProvider>().deleteProduct(id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$productName berhasil dihapus")),
                );
              }
            }, 
            child: const Text('Hapus', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}