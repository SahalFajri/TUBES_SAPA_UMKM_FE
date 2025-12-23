import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class SertifikasiDetailScreen extends StatefulWidget {
  const SertifikasiDetailScreen({super.key});

  @override
  State<SertifikasiDetailScreen> createState() =>
      _SertifikasiDetailScreenState();
}

class _SertifikasiDetailScreenState extends State<SertifikasiDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nikController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _namaUsahaController = TextEditingController();
  final _alamatUsahaController = TextEditingController();
  final _produkController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lembagaController = TextEditingController();

  // Dropdown
  String? _jenisSertifikasi;
  final List<String> _jenisList = [
    'Sertifikasi Halal',
    'Sertifikasi SNI',
    'Sertifikasi BPOM',
    'Sertifikasi ISO',
    'Lainnya',
  ];

  // Dokumen upload simulasi
  String? _fotoProduk;
  String? _dokumenPersyaratan;

  Future<void> _fakeUploadFile(String field) async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      if (field == 'foto') {
        _fotoProduk = 'Foto_Produk.png';
      } else {
        _dokumenPersyaratan = 'Dokumen_Persyaratan.pdf';
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Pengajuan sertifikasi berhasil dikirim!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Pengajuan Sertifikasi Usaha',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Data Pemilik Usaha'),
              _buildTextField(
                label: 'NIK (Nomor Induk Kependudukan)',
                icon: Icons.credit_card_rounded,
                controller: _nikController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                label: 'Nama Pemilik',
                icon: Icons.person_rounded,
                controller: _namaPemilikController,
              ),
              _buildTextField(
                label: 'Nama Usaha',
                icon: Icons.store_rounded,
                controller: _namaUsahaController,
              ),
              _buildTextField(
                label: 'Alamat Usaha',
                icon: Icons.home_rounded,
                controller: _alamatUsahaController,
                maxLines: 2,
              ),

              const SizedBox(height: 24),
              _sectionTitle('Data Sertifikasi'),
              _buildDropdown(
                label: 'Jenis Sertifikasi',
                icon: Icons.verified_rounded,
                value: _jenisSertifikasi,
                items: _jenisList,
                onChanged: (value) => setState(() => _jenisSertifikasi = value),
              ),
              _buildTextField(
                label: 'Produk yang Diajukan',
                icon: Icons.shopping_bag_rounded,
                controller: _produkController,
              ),
              _buildTextField(
                label: 'Deskripsi Produk',
                icon: Icons.description_rounded,
                controller: _deskripsiController,
                maxLines: 3,
              ),
              _buildTextField(
                label: 'Lembaga Sertifikasi Tujuan (Opsional)',
                icon: Icons.business_rounded,
                controller: _lembagaController,
                isRequired: false,
              ),

              const SizedBox(height: 24),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                title: 'Foto Produk (Wajib)',
                fileName: _fotoProduk,
                onUpload: () => _fakeUploadFile('foto'),
              ),
              _uploadTile(
                title: 'Dokumen Persyaratan (PDF)',
                fileName: _dokumenPersyaratan,
                onUpload: () => _fakeUploadFile('dokumen'),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kirim Pengajuan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Reusable Components =====

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppColors.textDark,
      ),
    ),
  );

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label wajib diisi';
          }
          return null;
        },
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: GoogleFonts.poppins(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: _inputDecoration(label, icon),
        validator: (val) => val == null ? 'Pilih $label' : null,
      ),
    );
  }

  Widget _uploadTile({
    required String title,
    String? fileName,
    required VoidCallback onUpload,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onUpload,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                fileName == null
                    ? Icons.upload_file_rounded
                    : Icons.check_circle_rounded,
                color: fileName == null ? Colors.grey : Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName ?? title,
                  style: GoogleFonts.poppins(
                    color: fileName == null ? Colors.grey[600] : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton(
                onPressed: onUpload,
                child: Text(
                  fileName == null ? 'Upload' : 'Ganti',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
