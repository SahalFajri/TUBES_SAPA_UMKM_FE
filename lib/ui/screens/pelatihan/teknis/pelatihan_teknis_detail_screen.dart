import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/technical_training_service.dart';

class PelatihanTeknisDetailScreen extends StatefulWidget {
  const PelatihanTeknisDetailScreen({super.key});

  @override
  State<PelatihanTeknisDetailScreen> createState() =>
      _PelatihanTeknisDetailScreenState();
}

class _PelatihanTeknisDetailScreenState
    extends State<PelatihanTeknisDetailScreen> {
  final TechnicalTrainingService _trainingService = TechnicalTrainingService();
  List<dynamic> _pelatihanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrainings();
  }

  // --- Ambil Data dari Backend ---
  Future<void> _fetchTrainings() async {
    setState(() => _isLoading = true);
    try {
      final data = await _trainingService.getTrainings();
      setState(() {
        _pelatihanList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Gagal memuat data pelatihan: $e", isError: true);
    }
  }

  // --- Proses Daftar Pelatihan ---
  Future<void> _daftarPelatihan(int id, String judul) async {
    // Tampilkan loading dialog sederhana
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await _trainingService.registerTraining(id);

    if (!mounted) return;
    Navigator.pop(context); // Tutup loading dialog

    if (result['success']) {
      _showSnackBar('✅ Berhasil mendaftar pelatihan "$judul"');
      _fetchTrainings(); // Refresh untuk update jumlah pendaftar/kuota
    } else {
      _showSnackBar(result['message'] ?? "Gagal mendaftar", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : AppColors.primary,
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
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
      body: RefreshIndicator(
        onRefresh: _fetchTrainings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _pelatihanList.length,
                itemBuilder: (context, index) {
                  final pelatihan = _pelatihanList[index];
                  final bool isFull = pelatihan['isFull'] ?? false;

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pelatihan['title'] ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              _buildQuotaBadge(pelatihan),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pelatihan['description'] ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: isFull
                                  ? null
                                  : () => _daftarPelatihan(
                                      pelatihan['id'],
                                      pelatihan['title'],
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFull
                                    ? Colors.grey
                                    : AppColors.primary,
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
                                isFull ? 'Kuota Penuh' : 'Daftar',
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
      ),
    );
  }

  Widget _buildQuotaBadge(dynamic pelatihan) {
    final int current = pelatihan['currentRegistrations'] ?? 0;
    final int total = pelatihan['quota'] ?? 0;
    final bool isFull = pelatihan['isFull'] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFull
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$current / $total Terisi',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isFull ? Colors.red : Colors.green[700],
        ),
      ),
    );
  }
}
