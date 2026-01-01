import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/inkubasi_service.dart';

class InkubasiFormScreen extends StatefulWidget {
  const InkubasiFormScreen({super.key});

  @override
  State<InkubasiFormScreen> createState() => _InkubasiFormScreenState();
}

class _InkubasiFormScreenState extends State<InkubasiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final InkubasiService _inkubasiService = InkubasiService();
  bool _isLoading = false;

  // Controllers
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _namaUsahaController = TextEditingController();
  final _deskripsiUsahaController = TextEditingController();

  // Dokumen Asli (Mandatory)
  PlatformFile? _proposalFile;
  PlatformFile? _fotoUsahaFile;

  // Error States untuk Inline Validation
  String? _emailError;
  String? _teleponError;
  String? _proposalError;
  String? _deskripsiError;

  void _resetErrors() {
    setState(() {
      _emailError = null;
      _teleponError = null;
      _proposalError = null;
      _deskripsiError = null;
    });
  }

  // Fungsi Pilih File Asli dengan filter format
  Future<void> _pickFile(bool isProposal) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: isProposal ? ['pdf'] : ['jpg', 'png', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        if (isProposal) {
          _proposalFile = result.files.first;
          _proposalError = null; // Clear error jika sudah pilih file
        } else {
          _fotoUsahaFile = result.files.first;
        }
      });
    }
  }

  void _submitForm() async {
    _resetErrors();

    if (_formKey.currentState!.validate()) {
      // Validasi Wajib File di Sisi Client
      if (_proposalFile == null || _fotoUsahaFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('⚠️ Proposal PDF dan Foto Usaha wajib diunggah!'),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Mapping data sesuai field backend
      Map<String, String> formData = {
        'namaLengkap': _namaController.text,
        'email': _emailController.text,
        'nomorTelepon': _teleponController.text,
        'namaUsaha': _namaUsahaController.text,
        'deskripsiUsaha': _deskripsiUsahaController.text,
      };

      final result = await _inkubasiService.submitInkubasi(
        data: formData,
        proposalFile: _proposalFile,
        fotoUsahaFile: _fotoUsahaFile,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              '✅ Pendaftaran Program Inkubasi berhasil dikirim!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        // Tangkap Error Spesifik dari Backend (Contoh: Format PDF salah)
        if (result['errors'] != null) {
          setState(() {
            for (String err in result['errors']) {
              String lowerErr = err.toLowerCase();
              if (lowerErr.contains('email')) _emailError = err;
              if (lowerErr.contains('telepon')) _teleponError = err;
              if (lowerErr.contains('deskripsi')) _deskripsiError = err;
              if (lowerErr.contains('pdf') || lowerErr.contains('proposal')) {
                _proposalError = err;
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
          'Pendaftaran Program Inkubasi',
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
              _sectionTitle('Data Pemohon'),
              _buildTextField(
                _namaController,
                'Nama Lengkap',
                Icons.person_rounded,
              ),
              _buildTextField(
                _emailController,
                'Email',
                Icons.email_rounded,
                errorText: _emailError,
              ),
              _buildTextField(
                _teleponController,
                'Nomor Telepon',
                Icons.phone_rounded,
                isNumber: true,
                errorText: _teleponError,
              ),
              const SizedBox(height: 28),
              _sectionTitle('Data Usaha'),
              _buildTextField(
                _namaUsahaController,
                'Nama Usaha',
                Icons.store_rounded,
              ),
              _buildTextField(
                _deskripsiUsahaController,
                'Deskripsi Singkat Usaha',
                Icons.assignment_rounded,
                maxLines: 3,
                errorText: _deskripsiError,
              ),
              const SizedBox(height: 28),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                'Proposal Inkubasi (Wajib PDF)',
                _proposalFile?.name,
                () => _pickFile(true),
                errorText: _proposalError,
              ),
              _uploadTile(
                'Foto Usaha / Produk (Wajib)',
                _fotoUsahaFile?.name,
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

  // --- Components ---
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

  Widget _uploadTile(
    String title,
    String? fileName,
    VoidCallback onUpload, {
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: onUpload,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: errorText != null ? Colors.red : Colors.grey.shade300,
                ),
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
                        color: fileName == null
                            ? Colors.grey[600]
                            : Colors.black87,
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
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
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
