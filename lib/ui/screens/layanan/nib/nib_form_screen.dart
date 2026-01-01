import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/nib_service.dart';

class NibFormScreen extends StatefulWidget {
  const NibFormScreen({super.key});

  @override
  State<NibFormScreen> createState() => _NibFormScreenState();
}

class _NibFormScreenState extends State<NibFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final NibService _nibService = NibService();
  bool _isLoading = false;

  // Controller
  final _nikController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _npwpController = TextEditingController();
  final _alamatPemilikController = TextEditingController();
  final _namaUsahaController = TextEditingController();
  final _alamatUsahaController = TextEditingController();
  final _modalController = TextEditingController();

  // --- VARIABEL ERROR STATE (BARU) ---
  String? _nikError;
  String? _namaPemilikError;
  String? _npwpError;
  String? _alamatPemilikError;
  String? _namaUsahaError;
  String? _alamatUsahaError;
  String? _modalError;
  // Note: Dropdown & File biasanya errornya via Snackbar atau validasi form default,
  // tapi bisa ditambah jika perlu.

  // Dropdown values
  String? _kbli;
  String? _sektorUsaha;
  String? _skalaUsaha;

  // File Variables
  PlatformFile? _fotoKtpFile;
  PlatformFile? _skdFileFile;

  final List<String> _kbliList = [
    '10792 - Perdagangan Kebutuhan Pokok',
    '56101 - Restoran & Rumah Makan',
    '14111 - Industri Pakaian Jadi',
    '62010 - Aktivitas Pemrograman Komputer',
  ];

  final List<String> _sektorList = [
    'Makanan & Minuman',
    'Kerajinan',
    'Jasa',
    'Teknologi',
    'Pertanian',
  ];

  final List<String> _skalaList = ['Mikro', 'Kecil', 'Menengah'];

  // Fungsi Pilih File Asli
  Future<void> _pickFile(bool isKtp) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        if (isKtp) {
          _fotoKtpFile = result.files.first;
        } else {
          _skdFileFile = result.files.first;
        }
      });
    }
  }

  // Fungsi Reset Error
  void _resetErrors() {
    setState(() {
      _nikError = null;
      _namaPemilikError = null;
      _npwpError = null;
      _alamatPemilikError = null;
      _namaUsahaError = null;
      _alamatUsahaError = null;
      _modalError = null;
    });
  }

  // Fungsi Submit Asli ke Backend
  void _submitForm() async {
    // 1. Reset error lama
    _resetErrors();

    if (_formKey.currentState!.validate()) {
      if (_fotoKtpFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('⚠️ Foto E-KTP Wajib diupload!'),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Mapping Data sesuai Backend
      Map<String, String> formData = {
        'nik': _nikController.text,
        'namaPemilik': _namaPemilikController.text,
        'npwp': _npwpController.text,
        'alamatPemilik': _alamatPemilikController.text,
        'namaUsaha': _namaUsahaController.text,
        'alamatUsaha': _alamatUsahaController.text,
        'kbli': _kbli ?? '',
        'sektorUsaha': _sektorUsaha ?? '',
        'skalaUsaha': _skalaUsaha ?? '',
        'modalUsaha': _modalController.text,
      };

      // Panggil Service
      // Perhatikan: Service harus mengembalikan Map (lihat panduan sebelumnya)
      // return type: Future<Map<String, dynamic>>
      final result = await _nibService.submitNib(
        data: formData,
        fotoKtp: _fotoKtpFile,
        skdFile: _skdFileFile,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        // SUKSES
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              '✅ Pengajuan izin usaha berhasil dikirim!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        // GAGAL

        // 1. Cek apakah ada list error spesifik
        if (result['errors'] != null && (result['errors'] as List).isNotEmpty) {
          List errors = result['errors'];

          // Mapping Error Backend ke Input Field
          setState(() {
            for (String err in errors) {
              String lowerErr = err.toLowerCase();
              if (lowerErr.contains('nik'))
                _nikError = err;
              else if (lowerErr.contains('nama pemilik'))
                _namaPemilikError = err;
              else if (lowerErr.contains('npwp'))
                _npwpError = err;
              else if (lowerErr.contains('alamat pemilik'))
                _alamatPemilikError = err;
              else if (lowerErr.contains('nama usaha'))
                _namaUsahaError = err;
              else if (lowerErr.contains('alamat lokasi usaha') ||
                  lowerErr.contains('alamat usaha'))
                _alamatUsahaError = err;
              else if (lowerErr.contains('modal'))
                _modalError = err;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Periksa inputan yang berwarna merah',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          );
        } else {
          // 2. Error umum (bukan validasi field)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                '❌ ${result['message']}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
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
          'Pengajuan Izin Usaha (NIB)',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Data Pemilik'),
              _buildTextField(
                label: 'NIK (Nomor Induk Kependudukan)',
                icon: Icons.credit_card_rounded,
                controller: _nikController,
                keyboardType: TextInputType.number,
                errorText: _nikError, // Pass error
              ),
              _buildTextField(
                label: 'Nama Lengkap Pemilik',
                icon: Icons.person_rounded,
                controller: _namaPemilikController,
                errorText: _namaPemilikError, // Pass error
              ),
              _buildTextField(
                label: 'NPWP Pribadi',
                icon: Icons.receipt_long_rounded,
                controller: _npwpController,
                keyboardType: TextInputType.number,
                errorText: _npwpError, // Pass error
              ),
              _buildTextField(
                label: 'Alamat Pemilik',
                icon: Icons.home_rounded,
                controller: _alamatPemilikController,
                maxLines: 2,
                errorText: _alamatPemilikError, // Pass error
              ),

              const SizedBox(height: 28),
              _sectionTitle('Data Usaha'),

              _buildTextField(
                label: 'Nama Usaha',
                icon: Icons.storefront_rounded,
                controller: _namaUsahaController,
                errorText: _namaUsahaError, // Pass error
              ),
              _buildTextField(
                label: 'Alamat Lokasi Usaha',
                icon: Icons.location_on_rounded,
                controller: _alamatUsahaController,
                maxLines: 2,
                errorText: _alamatUsahaError, // Pass error
              ),

              _buildDropdown(
                label: 'Kode KBLI',
                icon: Icons.code_rounded,
                value: _kbli,
                items: _kbliList,
                onChanged: (value) => setState(() => _kbli = value),
              ),
              _buildDropdown(
                label: 'Sektor Usaha',
                icon: Icons.category_rounded,
                value: _sektorUsaha,
                items: _sektorList,
                onChanged: (value) => setState(() => _sektorUsaha = value),
              ),
              _buildDropdown(
                label: 'Skala Usaha',
                icon: Icons.bar_chart_rounded,
                value: _skalaUsaha,
                items: _skalaList,
                onChanged: (value) => setState(() => _skalaUsaha = value),
              ),
              _buildTextField(
                label: 'Estimasi Modal Usaha (Rp)',
                icon: Icons.attach_money_rounded,
                controller: _modalController,
                keyboardType: TextInputType.number,
                errorText: _modalError, // Pass error
              ),

              const SizedBox(height: 28),
              _sectionTitle('Dokumen Pendukung'),

              _uploadTile(
                title: 'Foto E-KTP (Wajib)',
                fileName: _fotoKtpFile?.name,
                onUpload: () => _pickFile(true),
              ),
              _uploadTile(
                title: 'Surat Keterangan Domisili (Opsional)',
                fileName: _skdFileFile?.name,
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
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
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

  // 🔹 COMPONENTS
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
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
    String? errorText, // <-- Tambahan Parameter Error
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) =>
            (value == null || value.isEmpty) ? '$label wajib diisi' : null,
        // Gunakan parameter errorText di decoration
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: _inputDecoration(label, icon, null),
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

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    String? errorText,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,

      // KONFIGURASI ERROR TEXT DISINI
      errorText: errorText,
      errorStyle: GoogleFonts.poppins(color: Colors.red, fontSize: 12),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
      // Style saat error (Border jadi merah)
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
