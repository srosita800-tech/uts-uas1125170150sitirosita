import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // State utama: false untuk Light Mode, true untuk Dark Mode
  bool _isDark = false;   

  // Getter untuk mengecek status di UI (misal: untuk warna teks)
  bool get isDark => _isDark;

  // Getter untuk dibaca oleh MaterialApp (menggunakan ThemeMode bawaan Flutter)
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  // Fungsi untuk berpindah mode
  void toggle() {
    _isDark = !_isDark; 
    notifyListeners(); // Memberitahu semua halaman untuk berubah warna
  }
}

/** * CATATAN PENTING: 
 * Jangan tambahkan 'enum ThemeMode' di sini karena Flutter 
 * sudah menyediakannya secara bawaan di dalam material.dart. 
 * Jika ditambah, kode akan error (Ambiguous definition).
 */