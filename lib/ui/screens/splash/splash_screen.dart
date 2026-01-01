import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart'; // 1. Import Auth Service

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  // 2. Inisialisasi Service
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Timer Animasi (TIDAK BERUBAH)
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Timer Navigasi (INI YANG KITA UPDATE)
    Timer(const Duration(seconds: 3), () async {
      // 3. Cek Token saat splash screen muncul
      String? token = await _authService.getToken();

      // Cek mounted agar tidak error jika widget sudah ditutup
      if (!mounted) return;

      if (token != null) {
        // JIKA ADA TOKEN -> Langsung ke Dashboard
        // Kita pakai route '/dashboard' yang sudah ada di app_routes.dart kamu
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // JIKA TIDAK ADA -> Ke Login
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // UI TIDAK DIUBAH SAMA SEKALI
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.storefront_rounded, color: Colors.white, size: 100),
              SizedBox(height: 20),
              Text(
                "Sapa UMKM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Melayani & Memberdayakan UMKM Indonesia",
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
