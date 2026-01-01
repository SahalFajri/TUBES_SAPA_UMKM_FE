import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/kur_service.dart';

class KurFormScreen extends StatefulWidget {
  const KurFormScreen({super.key});

  @override
  State<KurFormScreen> createState() => _KurFormScreenState();
}

class _KurFormScreenState extends State<KurFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final KurService _kurService = KurService();
  bool _isLoading = false;

  // Controllers
  final _namaPemilikController = TextEditingController();
  final _nikController = TextEditingController();
  final _namaUsahaController = TextEditingController();
  final _alamatUsahaController = TextEditingController();
  final _jumlahPinjamanController = TextEditingController();
  final _tujuanPinjamanController = TextEditingController();

  // Error States (Untuk Inline Validation dari Backend)
  String? _nikError;
  String? _namaPemilikError;
  String? _namaUsahaError;
  String? _jumlahPinjamanError;

  // Dropdown values
  String? _jenisUsaha;
  String? _jangkaWaktu;

  final List<String> _jenisUsahaList = [
    'Perdagangan',
    'Kuliner',
    'Jasa',
    'Pertanian',
    'Teknologi',
  ];

  final List<String> _jangkaWaktuList = [
    '6 Bulan',
    '12 Bulan',
    '24 Bulan',
    '36 Bulan',
  ];

  // Dokumen Asli
  PlatformFile? _ktpPlatformFile;
  PlatformFile? _skuPlatformFile;

  // Fungsi Reset Error
  void _resetErrors() {
    setState(() {
      _nikError = null;
      _namaPemilikError = null;
      _namaUsahaError = null;
      _jumlahPinjamanError = null;
    });
  }

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
          _ktpPlatformFile = result.files.first;
        } else {
          _skuPlatformFile = result.files.first;
        }
      });
    }
  }

  // Fungsi Submit ke Service
  void _submitForm() async {
    _resetErrors();

    if (_formKey.currentState!.validate()) {
      if (_ktpPlatformFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('⚠️ Foto E-KTP Pemilik Wajib diupload!'),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      Map<String, String> formData = {
        'namaPemilik': _namaPemilikController.text,
        'nik': _nikController.text,
        'namaUsaha': _namaUsahaController.text,
        'alamatUsaha': _alamatUsahaController.text,
        'jenisUsaha': _jenisUsaha ?? '',
        'jumlahPinjaman': _jumlahPinjamanController.text,
        'tujuanPinjaman': _tujuanPinjamanController.text,
        'jangkaWaktu': _jangkaWaktu ?? '',
      };

      final result = await _kurService.submitKur(
        data: formData,
        ktpFile: _ktpPlatformFile,
        suratUsahaFile: _skuPlatformFile,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              '✅ Pengajuan Program KUR berhasil dikirim!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        // Mapping Error Backend ke UI
        if (result['errors'] != null) {
          setState(() {
            for (String err in result['errors']) {
              String lowerErr = err.toLowerCase();
              if (lowerErr.contains('nik'))
                _nikError = err;
              else if (lowerErr.contains('pemilik'))
                _namaPemilikError = err;
              else if (lowerErr.contains('usaha'))
                _namaUsahaError = err;
              else if (lowerErr.contains('pinjaman'))
                _jumlahPinjamanError = err;
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
          'Pengajuan Program KUR',
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
              _sectionTitle('Data Pemilik Usaha'),
              _buildTextField(
                label: 'Nama Pemilik',
                icon: Icons.person_rounded,
                controller: _namaPemilikController,
                errorText: _namaPemilikError,
              ),
              _buildTextField(
                label: 'NIK (Nomor Induk Kependudukan)',
                icon: Icons.credit_card_rounded,
                controller: _nikController,
                keyboardType: TextInputType.number,
                errorText: _nikError,
              ),

              const SizedBox(height: 28),
              _sectionTitle('Data Usaha'),
              _buildTextField(
                label: 'Nama Usaha',
                icon: Icons.store_rounded,
                controller: _namaUsahaController,
                errorText: _namaUsahaError,
              ),
              _buildTextField(
                label: 'Alamat Usaha',
                icon: Icons.location_on_rounded,
                controller: _alamatUsahaController,
                maxLines: 2,
              ),
              _buildDropdown(
                label: 'Jenis Usaha',
                icon: Icons.category_rounded,
                value: _jenisUsaha,
                items: _jenisUsahaList,
                onChanged: (val) => setState(() => _jenisUsaha = val),
              ),

              const SizedBox(height: 28),
              _sectionTitle('Data Pengajuan'),
              _buildTextField(
                label: 'Jumlah Pinjaman (Rp)',
                icon: Icons.attach_money_rounded,
                controller: _jumlahPinjamanController,
                keyboardType: TextInputType.number,
                errorText: _jumlahPinjamanError,
              ),
              _buildTextField(
                label: 'Tujuan Pinjaman',
                icon: Icons.assignment_rounded,
                controller: _tujuanPinjamanController,
                maxLines: 2,
              ),
              _buildDropdown(
                label: 'Jangka Waktu Pinjaman',
                icon: Icons.timer_rounded,
                value: _jangkaWaktu,
                items: _jangkaWaktuList,
                onChanged: (val) => setState(() => _jangkaWaktu = val),
              ),

              const SizedBox(height: 28),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                title: 'Foto E-KTP Pemilik (Wajib)',
                fileName: _ktpPlatformFile?.name,
                onUpload: () => _pickFile(true),
              ),
              _uploadTile(
                title: 'Surat Keterangan Usaha (Opsional)',
                fileName: _skuPlatformFile?.name,
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

  // ===== Helpers (Sesuai Standar Layanan Sebelumnya) =====

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
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) =>
            (value == null || value.isEmpty) ? '$label wajib diisi' : null,
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
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
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
      errorText: errorText, // Inline validation error
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
