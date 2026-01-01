import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/sertifikasi_service.dart';
import 'sertifikasi_form_screen.dart'; // Pastikan nama file sesuai

class SertifikasiListScreen extends StatefulWidget {
  const SertifikasiListScreen({super.key});

  @override
  State<SertifikasiListScreen> createState() => _SertifikasiListScreenState();
}

class _SertifikasiListScreenState extends State<SertifikasiListScreen> {
  final SertifikasiService _sertifikasiService = SertifikasiService();
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _historyFuture = _sertifikasiService.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Riwayat Sertifikasi Usaha',
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
          // Navigasi ke Form Pengajuan
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SertifikasiFormScreen(),
            ),
          );
          _loadData(); // Refresh list saat kembali
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

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return _buildSertifikasiCard(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada pengajuan sertifikasi",
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Refresh", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSertifikasiCard(Map<String, dynamic> item) {
    final String status = (item['status'] ?? 'pending')
        .toString()
        .toLowerCase();

    return GestureDetector(
      onTap: () => _showDetailDialog(item),
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
                _buildStatusBadge(status),
                Text(
                  (item['createdAt'] ?? '').toString().split('T')[0],
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item['produk'] ?? 'Nama Produk',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 14,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 6),
                Text(
                  item['jenisSertifikasi'] ?? '-',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'approved'
        ? Colors.green
        : (status == 'rejected' ? Colors.red : Colors.orange);
    String label = status == 'approved'
        ? "Disetujui"
        : (status == 'rejected' ? "Ditolak" : "Pending");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                "Detail Pengajuan Sertifikasi",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 32),

              _detailItem("Jenis Sertifikasi", item['jenisSertifikasi']),
              _detailItem("Nama Produk", item['produk']),
              _detailItem("Deskripsi Produk", item['deskripsi']),
              _detailItem("Lembaga Tujuan", item['lembaga']),
              const Divider(height: 32),

              _detailItem("Nama Usaha", item['namaUsaha']),
              _detailItem("Nama Pemilik", item['namaPemilik']),
              _detailItem("NIK Pemilik", item['nik']),
              _detailItem("Alamat Usaha", item['alamatUsaha']),
              const SizedBox(height: 20),

              Text(
                "Dokumen Pendukung",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _buildDocTile("Foto Produk", item['fotoProduk']),
              _buildDocTile("Dokumen Persyaratan", item['dokumenPersyaratan']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, dynamic value) {
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

  Widget _buildDocTile(String title, String? filename) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.file_copy_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: GoogleFonts.poppins(fontSize: 13)),
          ),
          Text(
            filename != null ? "Terunggah" : "Kosong",
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
}
