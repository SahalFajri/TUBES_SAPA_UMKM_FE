import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/pelaporan_kegiatan_service.dart';
import 'pelaporan_kegiatan_form_screen.dart'; // Nama class form Anda

class PelaporanKegiatanListScreen extends StatefulWidget {
  const PelaporanKegiatanListScreen({super.key});

  @override
  State<PelaporanKegiatanListScreen> createState() =>
      _PelaporanKegiatanListScreenState();
}

class _PelaporanKegiatanListScreenState
    extends State<PelaporanKegiatanListScreen> {
  final PelaporanKegiatanService _service = PelaporanKegiatanService();
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _historyFuture = _service.getHistory();
    });
  }

  // Fungsi format rupiah manual tanpa library intl
  String _formatCurrency(dynamic amount) {
    if (amount == null) return "Rp 0";
    String str = amount.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return "Rp $result";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Riwayat Pelaporan Usaha',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PelaporanKegiatanFormScreen(),
            ),
          );
          _loadData();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return _buildReportCard(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _showDetailDialog(item), // Klik untuk lihat detail
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['jenisLaporan'] ?? '-',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  item['periode'] ?? '-',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow(Icons.store_rounded, item['namaUsaha'] ?? '-'),
            const SizedBox(height: 8),
            _infoRow(Icons.payments_rounded, _formatCurrency(item['omzet'])),
            const SizedBox(height: 8),
            _infoRow(
              Icons.trending_up_rounded,
              "Kondisi: ${item['perkembangan']}",
            ),
          ],
        ),
      ),
    );
  }

  // --- Fungsi Munculkan Detail Laporan ---
  void _showDetailDialog(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Detail Laporan Kegiatan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 32),

              _detailRow("Nama Usaha", item['namaUsaha']),
              _detailRow(
                "Periode & Jenis",
                "${item['periode']} (${item['jenisLaporan']})",
              ),
              _detailRow("Total Omzet", _formatCurrency(item['omzet'])),
              _detailRow("Perkembangan Usaha", item['perkembangan']),
              _detailRow("Kendala", item['kendala'] ?? "Tidak ada kendala"),
              _detailRow("Rencana Pengembangan", item['rencana']),

              const Divider(height: 32),
              Text(
                "Dokumen Lampiran",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _docItem("Laporan Keuangan / Pendukung", item['dokumenFile']),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Komponen Pendukung Detail ---
  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 2),
          Text(
            value?.toString() ?? '-',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _docItem(String label, String? filename) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_rounded,
            color: filename != null ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(fontSize: 13)),
          ),
          Text(
            filename != null ? "Terlampir" : "Kosong",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: filename != null ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada laporan kegiatan",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
