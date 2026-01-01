import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../../services/auth_service.dart'; // 1. Import Service

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 2. Inisialisasi Service & State Loading
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // 3. Fungsi Handle Register
  void _handleRegister() async {
    // Validasi input kosong di sisi aplikasi (UX lebih cepat)
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua kolom harus diisi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Panggil Service
    String? errorMessage = await _authService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      // SUKSES
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi Berhasil! Silakan Login."),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman Login
      Navigator.pop(context);
    } else {
      // GAGAL (Tampilkan pesan error dari Backend/Joi)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
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
              "Daftar Akun Baru",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Bergabung sebagai pelaku UMKM dan akses semua layanan.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              label: "Nama Lengkap",
              icon: Icons.person_outline,
              controller: nameController,
            ),
            const SizedBox(height: 16),
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

            // 4. Update Tombol
            CustomButton(
              text: _isLoading ? "Memproses..." : "Daftar",
              onPressed: _isLoading ? null : _handleRegister, // Panggil fungsi
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sudah punya akun? "),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Masuk di sini",
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
