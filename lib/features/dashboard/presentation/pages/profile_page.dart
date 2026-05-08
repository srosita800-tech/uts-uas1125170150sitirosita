import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../admin/kelola-produk/pages/admin_product_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/routes/app_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userFirebase = auth.firebaseUser;
    final userBackend = auth.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- HEADER PROFIL ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: userFirebase?.photoURL != null 
                        ? NetworkImage(userFirebase!.photoURL!) 
                        : null,
                    child: userFirebase?.photoURL == null 
                        ? const Icon(Icons.person, size: 50, color: Colors.blueAccent)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userBackend?['name'] ?? userFirebase?.displayName ?? 'Nama Pengguna',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userFirebase?.email ?? 'email@domain.com',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  // Badge Role (Tetap muncul berdasarkan data asli)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: auth.isAdmin ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      auth.isAdmin ? 'ADMIN' : 'USER',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: auth.isAdmin ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- MENU PILIHAN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // MENU KELOLA PRODUK (DIPAKSA MUNCUL UNTUK DEMO)
                  _buildProfileMenu(
                    icon: Icons.inventory_2_outlined,
                    title: 'Kelola Produk',
                    color: const Color.fromARGB(255, 255, 82, 137),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminProductPage()),
                      );
                    },
                  ),
                  const Divider(),
                  
                  _buildProfileMenu(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan Akun',
                    onTap: () {},
                  ),
                  _buildProfileMenu(
                    icon: Icons.history_rounded,
                    title: 'Riwayat Transaksi',
                    onTap: () {},
                  ),
                  _buildProfileMenu(
                    icon: Icons.shield_outlined,
                    title: 'Keamanan',
                    onTap: () {},
                  ),
                  const Divider(height: 40),
                  
                  // --- TOMBOL LOGOUT ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, AppRouter.login);
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      label: const Text('Keluar dari Akun', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk List Menu
  Widget _buildProfileMenu({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap,
    Color color = Colors.blueAccent, 
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}