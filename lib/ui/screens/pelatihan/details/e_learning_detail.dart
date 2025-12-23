import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ELearningDetail extends StatelessWidget {
  const ELearningDetail({super.key});

  final List<Map<String, String>> _modulList = const [
    {
      'judul': 'Dasar-Dasar Manajemen UMKM',
      'deskripsi': 'Modul ini membahas manajemen dasar UMKM untuk pemula.',
    },
    {
      'judul': 'Strategi Pemasaran Digital',
      'deskripsi':
          'Pelajari strategi pemasaran digital untuk meningkatkan penjualan.',
    },
    {
      'judul': 'Pengelolaan Keuangan UMKM',
      'deskripsi':
          'Modul untuk memahami pengelolaan keuangan usaha secara efektif.',
    },
    {
      'judul': 'Inovasi Produk & Layanan',
      'deskripsi': 'Belajar cara mengembangkan produk agar lebih kompetitif.',
    },
  ];

  void _bukaModul(BuildContext context, String judul) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(
          '📖 Modul "$judul" dibuka!',
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
          'E-Learning UMKM',
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
        itemCount: _modulList.length,
        itemBuilder: (context, index) {
          final modul = _modulList[index];
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
                    modul['judul']!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    modul['deskripsi']!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _bukaModul(context, modul['judul']!),
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
                        'Buka Modul',
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
