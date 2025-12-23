import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class InkubasiDetailScreen extends StatefulWidget {
  const InkubasiDetailScreen({super.key});

  @override
  State<InkubasiDetailScreen> createState() => _InkubasiDetailScreenState();
}

class _InkubasiDetailScreenState extends State<InkubasiDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _namaUsahaController = TextEditingController();
  final _deskripsiUsahaController = TextEditingController();

  // Dummy upload
  String? _proposalFile;
  String? _fotoUsahaFile;

  Future<void> _fakeUpload(String field) async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      if (field == 'proposal') {
        _proposalFile = 'Proposal_Inkubasi.pdf';
      } else {
        _fotoUsahaFile = 'Foto_Usaha.png';
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
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
              _buildTextField(_emailController, 'Email', Icons.email_rounded),
              _buildTextField(
                _teleponController,
                'Nomor Telepon',
                Icons.phone_rounded,
                isNumber: true,
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
              ),

              const SizedBox(height: 28),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                'Proposal Inkubasi (PDF)',
                _proposalFile,
                () => _fakeUpload('proposal'),
              ),
              _uploadTile(
                'Foto Usaha / Produk',
                _fotoUsahaFile,
                () => _fakeUpload('foto'),
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

  // 🔹 Components
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? '$label wajib diisi' : null,
        decoration: _inputDecoration(label, icon),
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
