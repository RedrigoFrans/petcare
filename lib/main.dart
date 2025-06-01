import 'package:flutter/material.dart';
import 'Api/session_manager.dart'; // ✅ Impor SessionManager
import 'Screens/splash1.dart';     // ✅ Layar splash awal jika belum login
import 'Screens/dashboard.dart';  // ✅ Layar dashboard jika sudah login
// Pastikan path impor sesuai dengan struktur proyek Anda

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Penting untuk operasi async sebelum runApp
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SessionManager _sessionManager = SessionManager();
  bool _isLoading = true; // Status untuk menampilkan loading saat pengecekan
  bool _isLoggedIn = false; // Status login pengguna

  @override
  void initState() {
    super.initState();
    _cekStatusLogin();
  }

  Future<void> _cekStatusLogin() async {
    // Beri sedikit jeda agar tidak terlalu cepat jika prosesnya instan
    // await Future.delayed(Duration(milliseconds: 500));
    bool sudahLogin = await _sessionManager.isLoggedIn();
    if (mounted) { // Pastikan widget masih ada di tree
      setState(() {
        _isLoggedIn = sudahLogin;
        _isLoading = false; // Selesai loading, siap tampilkan halaman
      });
      if (sudahLogin) {
        print("Pengguna sudah login, langsung ke Dashboard.");
      } else {
        print("Pengguna belum login, mulai dari Splash1.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Tampilkan layar loading sederhana selagi mengecek status login
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Atau splash screen minimal
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Nama Aplikasi Anda', // Ganti dengan nama aplikasi Anda
      theme: ThemeData(
        primarySwatch: Colors.green, // Sesuaikan dengan tema aplikasi Anda
        // Tambahkan konfigurasi tema lainnya di sini
      ),
      // Tentukan halaman awal berdasarkan status login
      home: _isLoggedIn ? const Dashboard() : const Splash1(),
      debugShowCheckedModeBanner: false,
      // Anda bisa mendefinisikan rute di sini jika menggunakan navigasi bernama (named routes)
      // routes: {
      //   '/login': (context) => const Login(),
      //   '/dashboard': (context) => const Dashboard(),
      //   // ... rute lainnya
      // },
    );
  }
}