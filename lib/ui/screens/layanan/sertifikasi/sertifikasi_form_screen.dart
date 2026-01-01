import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/sertifikasi_service.dart';

class SertifikasiFormScreen extends StatefulWidget {
  const SertifikasiFormScreen({super.key});

  @override
  State<SertifikasiFormScreen> createState() => _SertifikasiFormScreenState();
}

class _SertifikasiFormScreenState extends State<SertifikasiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SertifikasiService _sertifikasiService = SertifikasiService();
  bool _isLoading = false;

  // Controllers
  final _nikController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _namaUsahaController = TextEditingController();
  final _alamatUsahaController = TextEditingController();
  final _produkController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lembagaController = TextEditingController();

  // Error States (Untuk Inline Validation dari Backend)
  String? _nikError,
      _namaPemilikError,
      _namaUsahaError,
      _produkError,
      _deskripsiError,
      _jenisError;

  // Dropdown
  String? _jenisSertifikasi;
  final List<String> _jenisList = [
    'Sertifikasi Halal',
    'Sertifikasi SNI',
    'Sertifikasi BPOM',
    'Sertifikasi ISO',
    'Lainnya',
  ];

  // Dokumen Asli
  PlatformFile? _fotoProduk;
  PlatformFile? _dokumenPersyaratan;

  // Fungsi Reset Error
  void _resetErrors() {
    setState(() {
      _nikError = null;
      _namaPemilikError = null;
      _namaUsahaError = null;
      _produkError = null;
      _deskripsiError = null;
      _jenisError = null;
    });
  }

  // Fungsi Pilih File Asli
  Future<void> _pickFile(bool isFoto) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        if (isFoto) {
          _fotoProduk = result.files.first;
        } else {
          _dokumenPersyaratan = result.files.first;
        }
      });
    }
  }

  // Fungsi Submit ke Service
  void _submitForm() async {
    _resetErrors();

    if (_formKey.currentState!.validate()) {
      if (_fotoProduk == null || _dokumenPersyaratan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              '⚠️ Foto Produk dan Dokumen Persyaratan wajib diupload!',
            ),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      Map<String, String> formData = {
        'nik': _nikController.text,
        'namaPemilik': _namaPemilikController.text,
        'namaUsaha': _namaUsahaController.text,
        'alamatUsaha': _alamatUsahaController.text,
        'jenisSertifikasi': _jenisSertifikasi ?? '',
        'produk': _produkController.text,
        'deskripsi': _deskripsiController.text,
        'lembaga': _lembagaController.text,
      };

      final result = await _sertifikasiService.submitSertifikasi(
        data: formData,
        fotoProduk: _fotoProduk,
        dokumenPersyaratan: _dokumenPersyaratan,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              '✅ Pengajuan sertifikasi berhasil dikirim!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        // Pemetaan Error dari Backend (Joi)
        if (result['errors'] != null) {
          setState(() {
            for (String err in result['errors']) {
              String low = err.toLowerCase();
              if (low.contains('nik'))
                _nikError = err;
              else if (low.contains('pemilik'))
                _namaPemilikError = err;
              else if (low.contains('usaha'))
                _namaUsahaError = err;
              else if (low.contains('produk'))
                _produkError = err;
              else if (low.contains('deskripsi'))
                _deskripsiError = err;
              else if (low.contains('jenis'))
                _jenisError = err;
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('❌ ${result['message']}'),
            ),
          );
        }
      }
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
                errorText: _nikError,
              ),
              _buildTextField(
                label: 'Nama Pemilik',
                icon: Icons.person_rounded,
                controller: _namaPemilikController,
                errorText: _namaPemilikError,
              ),
              _buildTextField(
                label: 'Nama Usaha',
                icon: Icons.store_rounded,
                controller: _namaUsahaController,
                errorText: _namaUsahaError,
              ),
              _buildTextField(
                label: 'Alamat Usaha',
                icon: Icons.location_on_rounded, // Ikon lebih konsisten
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
                errorText: _jenisError,
              ),
              _buildTextField(
                label: 'Produk yang Diajukan',
                icon: Icons.shopping_bag_rounded,
                controller: _produkController,
                errorText: _produkError,
              ),
              _buildTextField(
                label: 'Deskripsi Produk',
                icon: Icons.description_rounded,
                controller: _deskripsiController,
                maxLines: 3,
                errorText: _deskripsiError,
              ),
              _buildTextField(
                label: 'Lembaga Sertifikasi Tujuan (Opsional)',
                icon: Icons.account_balance_rounded,
                controller: _lembagaController,
                isRequired: false,
              ),

              const SizedBox(height: 24),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                title: 'Foto Produk (Wajib)',
                fileName: _fotoProduk?.name,
                onUpload: () => _pickFile(true),
              ),
              _uploadTile(
                title: 'Dokumen Persyaratan (PDF)',
                fileName: _dokumenPersyaratan?.name,
                onUpload: () => _pickFile(false),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
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

  // ===== Helpers (Sesuai Standar NIB & Merek) =====

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
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) => (isRequired && (value == null || value.isEmpty))
            ? '$label wajib diisi'
            : null,
        decoration: _inputDecoration(label, icon, errorText),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? errorText,
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
        decoration: _inputDecoration(label, icon, errorText),
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
              Text(
                fileName == null ? 'Upload' : 'Ganti',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    String? errorText,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary),
      errorText: errorText, // Menampilkan error dari backend secara inline
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
