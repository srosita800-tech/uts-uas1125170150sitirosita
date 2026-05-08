import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashPage extends StatefulWidget {
  // Menambahkan Key parameter agar warning 'use_key_in_widget_constructors' hilang
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  // Menambahkan void untuk menghilangkan warning 'strict_top_level_inference'
  Future<void> _navigateToNext() async {
    // Tampilkan logo selama 3 detik
    await Future.delayed(const Duration(seconds: 3));

    // Cek status login
    final User? user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pastikan file logo.png ada di folder assets/images/
            Image.asset(
              'assets/images/logo.png', 
              width: 150,
              errorBuilder: (context, error, stackTrace) {
                // Jika gambar tidak ketemu, tampilkan icon gembok sementara
                return const Icon(Icons.lock, size: 100, color: Colors.blue);
              },
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}