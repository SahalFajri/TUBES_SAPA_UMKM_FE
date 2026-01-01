import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/komunitas_pelatihan_service.dart';

class PelatihanDetailScreen extends StatefulWidget {
  const PelatihanDetailScreen({super.key});

  @override
  State<PelatihanDetailScreen> createState() => _PelatihanDetailScreenState();
}

class _PelatihanDetailScreenState extends State<PelatihanDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();

  // Service & Data
  final KomunitasPelatihanService _pelatihanService =
      KomunitasPelatihanService();
  List<dynamic> _listPelatihanBackend = [];
  int? _selectedTrainingId;

  bool _isListLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailableTrainings();
  }

  // --- Ambil daftar pelatihan dari backend untuk dropdown ---
  Future<void> _fetchAvailableTrainings() async {
    try {
      final data = await _pelatihanService.getListPelatihan();
      setState(() {
        _listPelatihanBackend = data;
        _isListLoading = false;
      });
    } catch (e) {
      setState(() => _isListLoading = false);
      _showSnackBar("Gagal memuat daftar pelatihan: $e", isError: true);
    }
  }

  // --- Submit form ke backend ---
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedTrainingId != null) {
      setState(() => _isSubmitting = true);

      final result = await _pelatihanService.daftarPelatihan(
        trainingId: _selectedTrainingId!,
        namaLengkap: _namaController.text.trim(),
        email: _emailController.text.trim(),
        noHp: _noHpController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (result['success']) {
        _showSnackBar('✅ Pendaftaran pelatihan berhasil dikirim!');
        Navigator.pop(context);
      } else {
        // Handle error validasi atau error umum
        String errorMsg = result['message'] ?? 'Gagal mendaftar';
        if (result['errors'] != null) {
          errorMsg = (result['errors'] as List).join("\n");
        }
        _showSnackBar(errorMsg, isError: true);
      }
    } else if (_selectedTrainingId == null) {
      _showSnackBar("Silakan pilih pelatihan terlebih dahulu", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : AppColors.primary,
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Text(
          'Pendaftaran Pelatihan',
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
      body: _isListLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      'Nama Lengkap',
                      Icons.person_rounded,
                      _namaController,
                    ),
                    _buildTextField(
                      'Email',
                      Icons.email_rounded,
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      'No. HP',
                      Icons.phone_rounded,
                      _noHpController,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildDropdown(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Daftar Pelatihan',
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

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14),
        validator: (val) =>
            val == null || val.isEmpty ? '$label wajib diisi' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
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
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: _selectedTrainingId,
        icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
        items: _listPelatihanBackend.map((item) {
          return DropdownMenuItem<int>(
            value: item['id'],
            child: Text(
              item['title'] ?? '-',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedTrainingId = val),
        decoration: InputDecoration(
          labelText: 'Pilih Pelatihan',
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.school_rounded,
            color: AppColors.primary,
            size: 20,
          ),
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
        ),
        validator: (val) => val == null ? 'Pilih pelatihan' : null,
      ),
    );
  }
}
