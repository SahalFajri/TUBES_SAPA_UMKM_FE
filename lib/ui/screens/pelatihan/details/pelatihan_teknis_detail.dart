import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class PelatihanTeknisDetail extends StatelessWidget {
  const PelatihanTeknisDetail({super.key});

  final List<Map<String, String>> _pelatihanList = const [
    {
      'judul': 'Manajemen Usaha UMKM',
      'deskripsi':
          'Pelatihan manajemen untuk meningkatkan strategi dan efisiensi usaha.',
    },
    {
      'judul': 'Pemasaran & Digitalisasi',
      'deskripsi':
          'Pelatihan pemasaran digital untuk memperluas pasar dan omzet.',
    },
    {
      'judul': 'Teknis Produksi',
      'deskripsi':
          'Pelatihan teknik produksi untuk meningkatkan kualitas produk.',
    },
    {
      'judul': 'Pengembangan Produk',
      'deskripsi': 'Pelatihan inovasi produk agar lebih kompetitif di pasar.',
    },
  ];

  void _daftarPelatihan(BuildContext context, String judul) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(
          '✅ Berhasil mendaftar pelatihan "$judul"',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Pelatihan Teknis & Manajemen',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _pelatihanList.length,
        itemBuilder: (context, index) {
          final pelatihan = _pelatihanList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pelatihan['judul']!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pelatihan['deskripsi']!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () =>
                          _daftarPelatihan(context, pelatihan['judul']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Daftar',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
