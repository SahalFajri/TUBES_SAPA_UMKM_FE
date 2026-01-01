import 'package:flutter/material.dart';

// core screens
import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/register_screen.dart';
import '../ui/screens/dashboard/dashboard_screen.dart';

// fitur / menu screens

// Layanan
import '../ui/screens/layanan/layanan_screen.dart';
import '../ui/screens/layanan/nib/nib_list_screen.dart';
import '../ui/screens/layanan/merek/merek_list_screen.dart';
import '../ui/screens/layanan/sertifikasi/sertifikasi_list_screen.dart';

// Program
import '../ui/screens/program/program_screen.dart';
import '../ui/screens/program/kur/kur_list_screen.dart';
import '../ui/screens/program/umi/umi_list_screen.dart';
import '../ui/screens/program/lpdb/lpdb_list_screen.dart';
import '../ui/screens/program/inkubasi/inkubasi_list_screen.dart';

// Pelaporan
import '../ui/screens/pelaporan/pelaporan_screen.dart';
import '../ui/screens/pelaporan/kegiatan/pelaporan_kegiatan_list_screen.dart';
import '../ui/screens/pelaporan/profil_umkm/profil_umkm_form_screen.dart';

// Komunitas
import '../ui/screens/komunitas/komunitas_screen.dart';
import '../ui/screens/komunitas/forum/forum_list_screen.dart';
import '../ui/screens/komunitas/pelatihan/pelatihan_detail_screen.dart';
import '../ui/screens/komunitas/program_kemenkop/info_program_screen.dart';

// Pelatihan
import '../ui/screens/pelatihan/pelatihan_screen.dart';
import '../ui/screens/pelatihan/teknis/pelatihan_teknis_detail_screen.dart';
import '../ui/screens/pelatihan/elearning/e_learning_detail_screen.dart';

// Profile
import '../ui/screens/profile/profile_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    // entry
    '/': (context) => const SplashScreen(),
    '/splash': (context) => const SplashScreen(),

    // auth
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),

    // main
    '/dashboard': (context) => const DashboardScreen(),

    // fitur / menu

    // Layanan
    '/layanan': (context) => const LayananScreen(),
    '/layanan/izin-usaha': (context) => const NibListScreen(),
    '/layanan/merek-produk': (context) => const MerekListScreen(),
    '/layanan/sertifikasi': (context) => const SertifikasiListScreen(),

    // Program
    '/program': (context) => const ProgramScreen(),
    '/program/kur': (context) => const KurListScreen(),
    '/program/umi': (context) => const UmiListScreen(),
    '/program/lpdb': (context) => const LpdbListScreen(),
    '/program/inkubasi': (context) => const InkubasiListScreen(),

    // Pelaporan
    '/pelaporan': (context) => const PelaporanScreen(),
    '/pelaporan/kegiatan': (context) => const PelaporanKegiatanListScreen(),
    '/pelaporan/pembaruan': (context) => const ProfilUmkmFormScreen(),

    // Komunitas
    '/komunitas': (context) => const KomunitasScreen(),
    '/komunitas/forum': (context) => const ForumListScreen(),
    '/komunitas/pelatihan': (context) => const PelatihanDetailScreen(),
    '/komunitas/info-program': (context) => const InfoProgramScreen(),

    // Pelatihan
    '/pelatihan': (context) => const PelatihanScreen(),
    '/pelatihan/teknis-manajemen': (context) =>
        const PelatihanTeknisDetailScreen(),
    '/pelatihan/e-learning': (context) => const ELearningDetailScreen(),

    // Profile
    '/profile': (context) => const ProfileScreen(),
  };
}
