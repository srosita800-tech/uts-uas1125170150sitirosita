import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Aplikasi', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo atau Ikon Aplikasi
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 80,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aplikasi Katalog Tas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            // Deskripsi Aplikasi
            const Card(
              elevation: 0,
              color: Color(0xFFF5F7F9),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aplikasi ini dibuat untuk memenuhi UAS Pemrograman Mobile Lanjutan. '
                  'Sistem ini mengintegrasikan Flutter sebagai frontend, Firebase untuk autentikasi, '
                  'dan Golang sebagai backend untuk manajemen produk.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info Pengembang
            const Divider(),
            const ListTile(
              leading: Icon(Icons.person_outline, color: Colors.blueAccent),
              title: Text('Pengembang'),
              subtitle: Text('Siti Rosita - 1125170150'),
            ),
            const ListTile(
              leading: Icon(Icons.school_outlined, color: Colors.blueAccent),
              title: Text('Program Studi'),
              subtitle: Text('Teknik Informatika - Global Institute'),
            ),
            const ListTile(
              leading: Icon(Icons.code_rounded, color: Colors.blueAccent),
              title: Text('Teknologi'),
              subtitle: Text('Flutter, Dart, Golang, MySQL , Firebase'),
            ),
            
            const SizedBox(height: 40),
            const Text(
              '© 2026 Catalog Tas. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}