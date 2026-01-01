import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/lpdb_service.dart';

class LpdbFormScreen extends StatefulWidget {
  const LpdbFormScreen({super.key});

  @override
  State<LpdbFormScreen> createState() => _LpdbFormScreenState();
}

class _LpdbFormScreenState extends State<LpdbFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final LpdbService _lpdbService = LpdbService();
  bool _isLoading = false;

  // Controllers
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _namaUsahaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _jumlahDanaController = TextEditingController();
  final _tujuanController = TextEditingController();

  // Error States (Untuk Inline Validation)
  String? _nikError;
  String? _jumlahPinjamanError;

  // Dropdown values
  String? _jenisUsaha;
  String? _bentukBadanUsaha;
  final List<String> _jenisUsahaList = [
    'Pertanian',
    'Perdagangan',
    'Teknologi',
    'Industri Kreatif',
    'Jasa',
  ];
  final List<String> _bentukBadanUsahaList = [
    'Koperasi',
    'PT (Perseroan Terbatas)',
    'CV (Commanditaire Vennootschap)',
    'Usaha Perorangan',
  ];

  // Dokumen Asli
  PlatformFile? _ktpPlatformFile;
  PlatformFile? _proposalPlatformFile;

  // Fungsi Reset Error
  void _resetErrors() {
    setState(() {
      _nikError = null;
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
          _proposalPlatformFile = result.files.first;
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

      // Mapping data sesuai field di backend
      Map<String, String> formData = {
        'namaPemilik': _namaController.text,
        'nik': _nikController.text,
        'namaUsaha': _namaUsahaController.text,
        'alamatUsaha': _alamatController.text,
        'jenisUsaha': _jenisUsaha ?? '',
        'jumlahPinjaman': _jumlahDanaController.text,
        'tujuanPinjaman': _tujuanController.text,
      };

      final result = await _lpdbService.submitLpdb(
        data: formData,
        ktpFile: _ktpPlatformFile,
        skuFile:
            _proposalPlatformFile, // Proposal dipetakan ke skuFile di backend
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              '✅ Pendaftaran Program LPDB berhasil dikirim!',
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
              if (lowerErr.contains('nik')) _nikError = err;
              if (lowerErr.contains('pinjaman') || lowerErr.contains('dana')) {
                _jumlahPinjamanError = err;
              }
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('❌ ${result['message'] ?? "Terjadi kesalahan"}'),
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
          'Pendaftaran Program LPDB',
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
              _sectionTitle('Data Pemohon'),
              _buildTextField(
                _namaController,
                'Nama Lengkap',
                Icons.person_rounded,
              ),
              _buildTextField(
                _nikController,
                'NIK (Nomor Induk Kependudukan)',
                Icons.credit_card_rounded,
                isNumber: true,
                errorText: _nikError,
              ),

              const SizedBox(height: 28),
              _sectionTitle('Data Usaha'),
              _buildTextField(
                _namaUsahaController,
                'Nama Usaha',
                Icons.storefront_rounded,
              ),
              _buildTextField(
                _alamatController,
                'Alamat Usaha',
                Icons.location_on_rounded,
                maxLines: 2,
              ),
              _buildDropdown(
                'Jenis Usaha',
                Icons.category_rounded,
                _jenisUsaha,
                _jenisUsahaList,
                (v) => setState(() => _jenisUsaha = v),
              ),
              _buildDropdown(
                'Bentuk Badan Usaha',
                Icons.business_rounded,
                _bentukBadanUsaha,
                _bentukBadanUsahaList,
                (v) => setState(() => _bentukBadanUsaha = v),
              ),

              const SizedBox(height: 28),
              _sectionTitle('Rencana Dana Bergulir'),
              _buildTextField(
                _jumlahDanaController,
                'Jumlah Dana Diajukan (Rp)',
                Icons.attach_money_rounded,
                isNumber: true,
                errorText: _jumlahPinjamanError,
              ),
              _buildTextField(
                _tujuanController,
                'Tujuan Penggunaan Dana',
                Icons.assignment_rounded,
                maxLines: 2,
              ),

              const SizedBox(height: 28),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                'Foto E-KTP (Wajib)',
                _ktpPlatformFile?.name,
                () => _pickFile(true),
              ),
              _uploadTile(
                'Proposal Usaha / Rencana Bisnis',
                _proposalPlatformFile?.name,
                () => _pickFile(false),
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
                          'Kirim Pendaftaran',
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
      ),
    );
  }

  // 🔹 Components (Identik dengan standar modul sebelumnya)
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? '$label wajib diisi' : null,
        decoration: _inputDecoration(
          label,
          icon,
        ).copyWith(errorText: errorText),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
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
        decoration: _inputDecoration(label, icon),
        validator: (val) => val == null ? 'Pilih $label' : null,
      ),
    );
  }

  Widget _uploadTile(String title, String? fileName, VoidCallback onUpload) {
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
