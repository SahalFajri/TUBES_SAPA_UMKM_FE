import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/merek_service.dart';

class MerekFormScreen extends StatefulWidget {
  const MerekFormScreen({super.key});

  @override
  State<MerekFormScreen> createState() => _MerekFormScreenState();
}

class _MerekFormScreenState extends State<MerekFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MerekService _merekService = MerekService();
  bool _isLoading = false;

  // Controllers
  final _nikController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _alamatPemilikController = TextEditingController();
  final _namaMerekController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime? _tanggalDigunakan;

  // Error States (Untuk Inline Validation)
  String? _nikError;
  String? _namaPemilikError;
  String? _namaMerekError;
  String? _deskripsiError;
  String? _kategoriError;
  String? _tanggalError;

  // Dropdown & Files
  String? _kategori;
  final List<String> _kategoriList = [
    'Pakaian & Aksesoris',
    'Makanan & Minuman',
    'Kosmetik & Perawatan',
    'Teknologi & Elektronik',
    'Jasa Desain & Kreatif',
  ];

  PlatformFile? _logoFile;
  PlatformFile? _suratPernyataanFile;

  // Fungsi Reset Error
  void _resetErrors() {
    setState(() {
      _nikError = null;
      _namaPemilikError = null;
      _namaMerekError = null;
      _deskripsiError = null;
      _kategoriError = null;
      _tanggalError = null;
    });
  }

  // Fungsi Pilih File
  Future<void> _pickFile(bool isLogo) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        if (isLogo) {
          _logoFile = result.files.first;
        } else {
          _suratPernyataanFile = result.files.first;
        }
      });
    }
  }

  // Fungsi Pilih Tanggal
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

  // Fungsi Submit
  void _submitForm() async {
    _resetErrors();

    if (_formKey.currentState!.validate()) {
      if (_logoFile == null || _suratPernyataanFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('⚠️ Logo Merek dan Surat Pernyataan Wajib diupload!'),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      Map<String, String> formData = {
        'nik': _nikController.text,
        'namaPemilik': _namaPemilikController.text,
        'alamatPemilik': _alamatPemilikController.text,
        'namaMerek': _namaMerekController.text,
        'deskripsiMerek': _deskripsiController.text,
        'kategori': _kategori ?? '',
        'tanggalDigunakan':
            _tanggalDigunakan?.toIso8601String().split('T')[0] ?? '',
      };

      final result = await _merekService.submitMerek(
        data: formData,
        logoMerek: _logoFile,
        suratPernyataan: _suratPernyataanFile,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
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
      } else {
        // Mapping Error Backend ke UI
        if (result['errors'] != null) {
          setState(() {
            for (String err in result['errors']) {
              String lowerErr = err.toLowerCase();
              if (lowerErr.contains('nik'))
                _nikError = err;
              else if (lowerErr.contains('nama pemilik'))
                _namaPemilikError = err;
              else if (lowerErr.contains('nama merek'))
                _namaMerekError = err;
              else if (lowerErr.contains('deskripsi'))
                _deskripsiError = err;
              else if (lowerErr.contains('kategori'))
                _kategoriError = err;
              else if (lowerErr.contains('tanggal'))
                _tanggalError = err;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Periksa kembali inputan Anda'),
            ),
          );
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
                errorText: _nikError,
              ),
              _buildTextField(
                label: 'Nama Pemilik Merek',
                icon: Icons.person_rounded,
                controller: _namaPemilikController,
                errorText: _namaPemilikError,
              ),
              _buildTextField(
                label: 'Alamat Pemilik',
                icon: Icons.home_rounded,
                controller: _alamatPemilikController,
                maxLines: 2,
              ),

              const SizedBox(height: 28),
              _sectionTitle('Data Merek'),
              _buildTextField(
                label: 'Nama Merek',
                icon: Icons.label_rounded,
                controller: _namaMerekController,
                errorText: _namaMerekError,
              ),
              _buildTextField(
                label: 'Deskripsi Merek',
                icon: Icons.description_rounded,
                controller: _deskripsiController,
                maxLines: 3,
                errorText: _deskripsiError,
              ),
              _buildDropdown(
                label: 'Kategori Barang/Jasa',
                icon: Icons.category_rounded,
                value: _kategori,
                items: _kategoriList,
                onChanged: (value) => setState(() => _kategori = value),
                errorText: _kategoriError,
              ),
              _buildDatePicker(errorText: _tanggalError),

              const SizedBox(height: 28),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                title: 'Logo Merek (Wajib)',
                fileName: _logoFile?.name,
                onUpload: () => _pickFile(true),
              ),
              _uploadTile(
                title: 'Surat Pernyataan Kepemilikan (Wajib)',
                fileName: _suratPernyataanFile?.name,
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
                          'Kirim Pendaftaran',
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

  // --- Helpers ---
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
        validator: (val) => val == null ? 'Pilih $label' : null,
        decoration: _inputDecoration(label, icon, errorText),
      ),
    );
  }

  Widget _buildDatePicker({String? errorText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _pickDate,
        child: InputDecorator(
          decoration: _inputDecoration(
            'Tanggal Pertama Digunakan',
            Icons.date_range_rounded,
            errorText,
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
      errorText: errorText,
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
