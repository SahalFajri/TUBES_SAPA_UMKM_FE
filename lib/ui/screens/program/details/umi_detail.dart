import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class UmiDetailScreen extends StatefulWidget {
  const UmiDetailScreen({super.key});

  @override
  State<UmiDetailScreen> createState() => _UmiDetailScreenState();
}

class _UmiDetailScreenState extends State<UmiDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _namaUsahaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _nominalController = TextEditingController();
  final _tujuanController = TextEditingController();

  // Dropdowns
  String? _jenisUsaha;
  final List<String> _jenisUsahaList = [
    'Perdagangan',
    'Kuliner',
    'Jasa',
    'Pertanian',
    'Kerajinan',
  ];

  // Upload dummy
  String? _ktpFile;
  String? _skuFile;

  Future<void> _fakeUpload(String field) async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      if (field == 'ktp') {
        _ktpFile = 'KTP_Pemilik.png';
      } else {
        _skuFile = 'Surat_Keterangan_Usaha.pdf';
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            '✅ Pendaftaran Program UMi berhasil dikirim!',
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
          'Pendaftaran Program UMi',
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
                _namaController,
                'Nama Pemilik',
                Icons.person_rounded,
              ),
              _buildTextField(
                _nikController,
                'NIK (Nomor Induk Kependudukan)',
                Icons.credit_card_rounded,
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

              const SizedBox(height: 28),
              _sectionTitle('Detail Pembiayaan'),
              _buildTextField(
                _nominalController,
                'Nominal Pengajuan (Rp)',
                Icons.attach_money_rounded,
                isNumber: true,
              ),
              _buildTextField(
                _tujuanController,
                'Tujuan Pembiayaan',
                Icons.assignment_rounded,
                maxLines: 2,
              ),

              const SizedBox(height: 28),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                'Foto E-KTP Pemilik (Wajib)',
                _ktpFile,
                () => _fakeUpload('ktp'),
              ),
              _uploadTile(
                'Surat Keterangan Usaha (Opsional)',
                _skuFile,
                () => _fakeUpload('sku'),
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
