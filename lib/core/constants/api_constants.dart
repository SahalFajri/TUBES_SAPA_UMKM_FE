class ApiConstants {
  // Ganti IP ini sesuai dengan hasil pengecekan IP laptop kamu (lihat langkah mengatasi RTO di bawah)
  // Jangan lupa port 3000 dan prefix /api/auth sesuai route backend
  static const String baseUrl = "http://localhost:3000/api";

  // Endpoint Auth
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";

  // ## Layanan Route

  // Endpoint Layanan NIB
  static const String nibSubmit = "$baseUrl/layanan/nib/submit";
  static const String nibHistory = "$baseUrl/layanan/nib/history";

  // Endpoint Layanan Merek Produk
  static const String merekSubmit = "$baseUrl/layanan/merek/submit";
  static const String merekHistory = "$baseUrl/layanan/merek/history";

  // Endpoint Layanan Sertifikasi
  static const String sertifikasiSubmit = "$baseUrl/layanan/sertifikasi/submit";
  static const String sertifikasiHistory =
      "$baseUrl/layanan/sertifikasi/history";

  // ## Program Route

  // Endpoint Program KUR
  static const String kurSubmit = "$baseUrl/program/kur/submit";
  static const String kurHistory = "$baseUrl/program/kur/history";

  // Endpoint Program UMi
  static const String umiSubmit = "$baseUrl/program/umi/submit";
  static const String umiHistory = "$baseUrl/program/umi/history";

  // Endpoint Program LPDB
  static const String lpdbSubmit = "$baseUrl/program/lpdb/submit";
  static const String lpdbHistory = "$baseUrl/program/lpdb/history";

  // Endpoint Program Inkubasi
  static const String inkubasiSubmit = "$baseUrl/program/inkubasi/submit";
  static const String inkubasiHistory = "$baseUrl/program/inkubasi/history";

  // ## Pelaporan & Data Route

  // Endpoint Pelaporan Kegiatan
  static const String pelaporanSubmit =
      "$baseUrl/pelaporan-data/kegiatan/submit";
  static const String pelaporanHistory =
      "$baseUrl/pelaporan-data/kegiatan/history";

  // Endpoint Profil UMKM
  static const String profilUpdate = '$baseUrl/pelaporan-data/profil/update';
  static const String profilLatest = '$baseUrl/pelaporan-data/profil/latest';

  // ## Komunitas & Forum

  // Endpoint Forum
  static const String forumList = '$baseUrl/komunitas/forum';
  static const String forumCreate = '$baseUrl/komunitas/forum';
  static const String forumDetail =
      '$baseUrl/komunitas/forum'; // Digunakan: '$forumDetail/$id'
  static const String forumAddComment = '$baseUrl/komunitas/forum/comment';

  // Endpoint Pelatihan Komunitas
  static const String komunitasPelatihanList = '$baseUrl/komunitas/pelatihan';
  static const String komunitasPelatihanDaftar =
      '$baseUrl/komunitas/pelatihan/daftar';

  // Endpoint Program KemenKop
  static const String kemenkopProgramList =
      '$baseUrl/komunitas/kemenkop-program';

  // ## Pelatihan & E-Learning

  // Endpoint Pelatihan Teknis
  static const String pelatihanTeknisList = '$baseUrl/pelatihan/teknis';
  static const String pelatihanTeknisDaftar =
      '$baseUrl/pelatihan/teknis/daftar';

  // Endpoint E-Learning
  static const String elearningModulList = '$baseUrl/pelatihan/elearning';
}
