import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

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
  String? _pilihanPelatihan;

  final List<String> _pelatihanList = [
    'Digital Marketing',
    'Manajemen Keuangan',
    'Pengembangan Produk',
    'Teknologi UMKM',
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate() && _pilihanPelatihan != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            '✅ Pendaftaran pelatihan berhasil dikirim!',
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
          'Pendaftaran Pelatihan Komunitas',
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
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
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
        validator: (val) =>
            val == null || val.isEmpty ? '$label wajib diisi' : null,
        decoration: InputDecoration(
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
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _pilihanPelatihan,
        items: _pelatihanList
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: (val) => setState(() => _pilihanPelatihan = val),
        decoration: InputDecoration(
          labelText: 'Pilih Pelatihan',
          prefixIcon: Icon(Icons.school_rounded, color: AppColors.primary),
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
