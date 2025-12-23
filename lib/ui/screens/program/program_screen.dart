import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> programList = [
      {
        'title': 'Program KUR (Kredit Usaha Rakyat)',
        'icon': Icons.account_balance_rounded,
        'desc': 'Akses pembiayaan bunga rendah bagi UMKM.',
        'route': '/program/kur',
      },
      {
        'title': 'Program UMi (Ultra Mikro)',
        'icon': Icons.savings_rounded,
        'desc': 'Dukungan modal tanpa agunan untuk usaha kecil.',
        'route': '/program/umi',
      },
      {
        'title': 'Program LPDB (Dana Bergulir)',
        'icon': Icons.trending_up_rounded,
        'desc': 'Pendanaan bergulir dari KemenKopUKM untuk UMKM.',
        'route': '/program/lpdb',
      },
      {
        'title': 'Program Inkubasi & Bimbingan',
        'icon': Icons.school_rounded,
        'desc': 'Program pembinaan dan mentoring bisnis UMKM.',
        'route': '/program/inkubasi',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Text(
          'Program Pemberdayaan Pemerintah',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: programList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = programList[index];
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, item['route']);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Icon(
                        item['icon'] as IconData,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
