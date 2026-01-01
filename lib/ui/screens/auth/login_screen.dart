import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 1. Instansiasi AuthService
  final AuthService _authService = AuthService();

  bool _isLoading = false; // Untuk loading indicator

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final email = emailController.text;
    final password = passwordController.text;

    // Tampung hasil error message (bukan boolean lagi)
    String? errorMessage = await _authService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      // JIKA NULL = SUKSES
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Berhasil!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // JIKA ADA ISI = GAGAL (Tampilkan pesan error dari Backend/Joi)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage), // <-- INI KUNCINYA (Pesan Dinamis)
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sapa UMKM",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Masuk untuk mengelola dan mengakses layanan UMKM Anda.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              label: "Email",
              icon: Icons.email_outlined,
              controller: emailController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: "Kata Sandi",
              icon: Icons.lock_outline,
              isPassword: true,
              controller: passwordController,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: _isLoading ? "Loading..." : "Masuk",
              onPressed: _isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum punya akun? "),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    "Daftar Sekarang",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
