import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/elearning_service.dart';

class ELearningDetailScreen extends StatefulWidget {
  const ELearningDetailScreen({super.key});

  @override
  State<ELearningDetailScreen> createState() => _ELearningDetailScreenState();
}

class _ELearningDetailScreenState extends State<ELearningDetailScreen> {
  final ELearningService _elearningService = ELearningService();
  List<dynamic> _modulList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  // --- Ambil data modul dari backend ---
  Future<void> _fetchModules() async {
    setState(() => _isLoading = true);
    try {
      final data = await _elearningService.getModules();
      setState(() {
        _modulList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Gagal memuat modul E-Learning: $e", isError: true);
    }
  }

  // --- Fungsi untuk membuka link modul menggunakan url_launcher ---
  Future<void> _bukaModul(String? urlString, String judul) async {
    if (urlString == null || urlString.isEmpty) {
      _showSnackBar("Link modul tidak tersedia", isError: true);
      return;
    }

    final Uri url = Uri.parse(urlString);

    // Tampilkan pesan loading singkat
    _showSnackBar('📖 Membuka modul "$judul"...');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      _showSnackBar("Gagal membuka browser: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : AppColors.primary,
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
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
        elevation: 0,
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
      body: RefreshIndicator(
        onRefresh: _fetchModules,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _modulList.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
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
                          // Badge Kategori
                          if (modul['category'] != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                modul['category'].toString().toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          Text(
                            modul['title'] ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            modul['description'] ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _bukaModul(
                                modul['contentUrl'],
                                modul['title'],
                              ),
                              icon: const Icon(
                                Icons.menu_book_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Buka Modul',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
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
                            ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada modul tersedia.',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
