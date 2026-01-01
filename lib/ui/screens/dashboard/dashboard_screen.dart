import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart'; // 1. Import Service

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // [2] TAMBAHKAN FUNGSI INI UNTUK MENANGANI LOGOUT
  Future<void> _handleLogout(BuildContext context) async {
    // Tampilkan Dialog Konfirmasi
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Jika user batal, hentikan proses
    if (confirm != true) return;

    // Proses Logout (Hapus Token)
    final AuthService authService = AuthService();
    await authService.logout();

    // Cek apakah widget masih aktif sebelum navigasi
    if (!context.mounted) return;

    // Navigasi ke Login & Hapus history halaman agar tidak bisa di-back
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Layanan Publik',
        'icon': Icons.assignment_rounded,
        'route': '/layanan',
      },
      {
        'title': 'Program Pemerintah',
        'icon': Icons.volunteer_activism_rounded,
        'route': '/program',
      },
      {
        'title': 'Pelaporan Usaha',
        'icon': Icons.insert_chart_rounded,
        'route': '/pelaporan',
      },
      {
        'title': 'Komunitas & Forum',
        'icon': Icons.people_alt_rounded,
        'route': '/komunitas',
      },
      {
        'title': 'Pelatihan & E-Learning',
        'icon': Icons.school_rounded,
        'route': '/pelatihan',
      },
      {
        'title': 'Profil Saya', // Ganti judul
        'icon': Icons.account_circle_rounded, // Ganti ikon
        'route': '/profile', // Arahkan ke route profile
      },
      {'title': 'Keluar', 'icon': Icons.logout_rounded, 'route': '/login'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.storefront_rounded,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, Sahabat UMKM 👋",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Kembangkan bisnismu bersama SAPA UMKM",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 🔹 GRID MENU
              GridView.builder(
                itemCount: menuItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.05,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final bool isLogout = item['title'] == 'Keluar';

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (isLogout) {
                        _handleLogout(context);
                      } else {
                        Navigator.pushNamed(context, item['route'] as String);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: isLogout
                                ? Colors.redAccent
                                : AppColors.primary,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['title'] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isLogout
                                  ? Colors.redAccent
                                  : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
