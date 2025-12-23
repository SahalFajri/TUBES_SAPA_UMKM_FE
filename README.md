# Sapa UMKM (tubes_sapa_sahal)

Aplikasi Flutter sederhana untuk mendukung pelaku UMKM: layanan publik, program pemerintah, pelaporan usaha, komunitas, dan pelatihan.

Ringkasan cepat
- Entry app: [`SapaUmkmApp`](lib/main.dart) — lihat [lib/main.dart](lib/main.dart)  
- Daftar route: [`AppRoutes.routes`](lib/routes/app_routes.dart) — lihat [lib/routes/app_routes.dart](lib/routes/app_routes.dart)  
- Skema warna & konstanta: [`AppColors`](lib/core/constants/app_colors.dart) — lihat [lib/core/constants/app_colors.dart](lib/core/constants/app_colors.dart)  
- Contoh layar utama: [lib/ui/screens/dashboard/dashboard_screen.dart](lib/ui/screens/dashboard/dashboard_screen.dart)  
- Dependensi & aset: [pubspec.yaml](pubspec.yaml)

Struktur (singkat)
- lib/
  - main.dart — entry aplikasi ([lib/main.dart](lib/main.dart))
  - routes/app_routes.dart — pendaftaran route ([lib/routes/app_routes.dart](lib/routes/app_routes.dart))
  - core/constants/app_colors.dart — warna tema ([lib/core/constants/app_colors.dart](lib/core/constants/app_colors.dart))
  - ui/screens/... — layar fitur (dashboard, layanan, program, pelaporan, komunitas, pelatihan)

Prerequisites
- Flutter SDK terpasang dan PATH diset (sesuaikan dengan environment di [pubspec.yaml](pubspec.yaml)).
- Perangkat fisik atau emulator siap.

Cara menjalankan (lokal)
1. Buka terminal di root proyek (folder yang berisi [pubspec.yaml](pubspec.yaml)).  
2. Install dependency:
```bash
flutter pub get
```
3. Jalankan aplikasi pada device/emulator:
```bash
flutter run
```
4. Di VS Code: pilih device lalu tekan F5 atau gunakan Run → Start Debugging.

Build release
- Android APK:
```bash
flutter build apk --release
```
- iOS:
```bash
flutter build ios --release
```

Tips pengembangan cepat
- Tambah layar: buat file di `lib/ui/screens/...` lalu daftarkan route-nya di [`AppRoutes.routes`](lib/routes/app_routes.dart).  
- Gunakan warna konsisten melalui [`AppColors`](lib/core/constants/app_colors.dart).  
- Periksa aset yang terdaftar di [pubspec.yaml](pubspec.yaml) (mis. assets/images/logo.png).

Debugging
- Lihat output di terminal / Debug Console saat menjalankan `flutter run` atau debug di IDE.  
- Jika muncul error dependency, jalankan `flutter pub get` lalu `flutter clean` dan ulangi `flutter run`.

File penting cepat buka
- [lib/main.dart](lib/main.dart) — [`SapaUmkmApp`](lib/main.dart)  
- [lib/routes/app_routes.dart](lib/routes/app_routes.dart) — [`AppRoutes.routes`](lib/routes/app_routes.dart)  
- [lib/core/constants/app_colors.dart](lib/core/constants/app_colors.dart) — [`AppColors`](lib/core/constants/app_colors.dart)  
- [pubspec.yaml](pubspec.yaml)