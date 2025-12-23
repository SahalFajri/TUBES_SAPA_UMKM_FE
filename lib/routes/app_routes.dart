import 'package:flutter/material.dart';

// core screens
import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/register_screen.dart';
import '../ui/screens/dashboard/dashboard_screen.dart';

// fitur / menu screens

// Layanan
import '../ui/screens/layanan/layanan_screen.dart';
import '../ui/screens/layanan/details/izin_usaha_detail.dart';
import '../ui/screens/layanan/details/merek_produk_detail.dart';
import '../ui/screens/layanan/details/sertifikasi_detail.dart';

// Program
import '../ui/screens/program/program_screen.dart';
import '../ui/screens/program/details/kur_detail.dart';
import '../ui/screens/program/details/umi_detail.dart';
import '../ui/screens/program/details/lpdb_detail.dart';
import '../ui/screens/program/details/inkubasi_detail.dart';

// Pelaporan
import '../ui/screens/pelaporan/pelaporan_screen.dart';
import '../ui/screens/pelaporan/details/pelaporan_kegiatan_detail.dart';
import '../ui/screens/pelaporan/details/pembaruan_profil_detail.dart';

// Komunitas
import '../ui/screens/komunitas/komunitas_screen.dart';
import '../ui/screens/komunitas/details/forum_detail.dart';
import '../ui/screens/komunitas/details/pelatihan_detail.dart';
import '../ui/screens/komunitas/details/info_program_detail.dart';

// Pelatihan
import '../ui/screens/pelatihan/pelatihan_screen.dart';
import '../ui/screens/pelatihan/details/pelatihan_teknis_detail.dart';
import '../ui/screens/pelatihan/details/e_learning_detail.dart';

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
    '/layanan/izin-usaha': (context) => const IzinUsahaDetailScreen(),
    '/layanan/merek-produk': (context) => const MerekProdukDetailScreen(),
    '/layanan/sertifikasi': (context) => const SertifikasiDetailScreen(),

    // Program
    '/program': (context) => const ProgramScreen(),
    '/program/kur': (context) => const KurDetailScreen(),
    '/program/umi': (context) => const UmiDetailScreen(),
    '/program/lpdb': (context) => const LpdbDetailScreen(),
    '/program/inkubasi': (context) => const InkubasiDetailScreen(),

    // Pelaporan
    '/pelaporan': (context) => const PelaporanScreen(),
    '/pelaporan/kegiatan': (context) => const PelaporanKegiatanDetailScreen(),
    '/pelaporan/pembaruan': (context) => const PembaruanProfilDetailScreen(),

    // Komunitas
    '/komunitas': (context) => const KomunitasScreen(),
    '/komunitas/forum': (context) => const ForumDetailScreen(),
    '/komunitas/pelatihan': (context) => const PelatihanDetailScreen(),
    '/komunitas/info-program': (context) => const InfoProgramDetailScreen(),

    '/pelatihan': (context) => const PelatihanScreen(),
    '/pelatihan/teknis-manajemen': (context) => const PelatihanTeknisDetail(),
    '/pelatihan/e-learning': (context) => const ELearningDetail(),
  };
}
