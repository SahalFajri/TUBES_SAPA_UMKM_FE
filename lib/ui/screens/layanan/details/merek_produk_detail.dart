import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class MerekProdukDetailScreen extends StatefulWidget {
  const MerekProdukDetailScreen({super.key});

  @override
  State<MerekProdukDetailScreen> createState() =>
      _MerekProdukDetailScreenState();
}

class _MerekProdukDetailScreenState extends State<MerekProdukDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _nikController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _namaMerekController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime? _tanggalDigunakan;

  // Dropdown
  String? _kategori;
  final List<String> _kategoriList = [
    'Pakaian & Aksesoris',
    'Makanan & Minuman',
    'Kosmetik & Perawatan',
    'Teknologi & Elektronik',
    'Jasa Desain & Kreatif',
  ];

  // Dokumen
  String? _logoFile;
  String? _suratPernyataanFile;

  // Simulasi Upload
  Future<void> _fakeUploadFile(String field) async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      if (field == 'logo') {
        _logoFile = 'Logo_Merek.png';
      } else {
        _suratPernyataanFile = 'Surat_Pernyataan.pdf';
      }
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _tanggalDigunakan = picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            '✅ Pendaftaran merek berhasil dikirim!',
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
          'Registrasi Merek Produk',
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
              _sectionTitle('Data Pemilik Merek'),
              _buildTextField(
                label: 'NIK (Nomor Induk Kependudukan)',
                icon: Icons.credit_card_rounded,
                controller: _nikController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                label: 'Nama Pemilik Merek',
                icon: Icons.person_rounded,
                controller: _namaPemilikController,
              ),
              _buildTextField(
                label: 'Alamat Pemilik',
                icon: Icons.home_rounded,
                controller: _alamatController,
                maxLines: 2,
              ),

              const SizedBox(height: 28),
              _sectionTitle('Data Merek'),
              _buildTextField(
                label: 'Nama Merek',
                icon: Icons.label_rounded,
                controller: _namaMerekController,
              ),
              _buildTextField(
                label: 'Deskripsi Merek',
                icon: Icons.description_rounded,
                controller: _deskripsiController,
                maxLines: 3,
              ),
              _buildDropdown(
                label: 'Kategori Barang/Jasa',
                icon: Icons.category_rounded,
                value: _kategori,
                items: _kategoriList,
                onChanged: (value) => setState(() => _kategori = value),
              ),
              _buildDatePicker(),

              const SizedBox(height: 28),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                title: 'Logo Merek (Wajib)',
                fileName: _logoFile,
                onUpload: () => _fakeUploadFile('logo'),
              ),
              _uploadTile(
                title: 'Surat Pernyataan Kepemilikan (Wajib)',
                fileName: _suratPernyataanFile,
                onUpload: () => _fakeUploadFile('surat'),
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

  // ===== Helper Components =====
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) =>
            (value == null || value.isEmpty) ? '$label wajib diisi' : null,
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

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _pickDate,
        child: InputDecorator(
          decoration: _inputDecoration(
            'Tanggal Pertama Digunakan',
            Icons.date_range_rounded,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tanggalDigunakan == null
                    ? 'Belum dipilih'
                    : '${_tanggalDigunakan!.day}/${_tanggalDigunakan!.month}/${_tanggalDigunakan!.year}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
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
