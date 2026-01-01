import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/profil_umkm_service.dart';

class ProfilUmkmFormScreen extends StatefulWidget {
  const ProfilUmkmFormScreen({super.key});

  @override
  State<ProfilUmkmFormScreen> createState() => _ProfilUmkmFormScreenState();
}

class _ProfilUmkmFormScreenState extends State<ProfilUmkmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfilUmkmService _service = ProfilUmkmService();

  bool _isLoading = false;
  bool _isFetching = true; // Indikator saat mengambil data lama

  // Controllers
  final _namaUsahaController = TextEditingController();
  final _alamatUsahaController = TextEditingController();
  final _kontakController = TextEditingController();

  // Dropdown values
  String? _sektorUsaha;
  String? _skalaUsaha;

  // File picker
  PlatformFile? _dokumenFile;

  String? _existingDokumen; // Untuk nama file LAMA dari database

  // Error states dari backend
  String? _kontakError;

  final List<String> _sektorList = [
    'Makanan & Minuman',
    'Kerajinan',
    'Jasa',
    'Fashion',
    'Pertanian',
    'Teknologi',
  ];

  final List<String> _skalaList = ['Mikro', 'Kecil', 'Menengah'];

  @override
  void initState() {
    super.initState();
    _fetchLatestData();
  }

  // --- LOGIKA AUTO-FILL ---
  Future<void> _fetchLatestData() async {
    final data = await _service.getLatestProfile();

    if (data != null) {
      setState(() {
        _namaUsahaController.text = data['namaUsaha'] ?? '';
        _alamatUsahaController.text = data['alamatUsaha'] ?? '';
        _kontakController.text = data['kontak'] ?? '';

        // Simpan nama dokumen lama dari database
        _existingDokumen = data['dokumenFile'];

        if (_sektorList.contains(data['sektorUsaha']))
          _sektorUsaha = data['sektorUsaha'];
        if (_skalaList.contains(data['skalaUsaha']))
          _skalaUsaha = data['skalaUsaha'];
      });
    }
    setState(() => _isFetching = false);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _dokumenFile = result.files.first;
        _existingDokumen =
            null; // Sembunyikan indikator file lama karena sudah ada file baru
      });
    }
  }

  void _submitForm() async {
    setState(() => _kontakError = null);

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Map<String, String> formData = {
        'namaUsaha': _namaUsahaController.text,
        'alamatUsaha': _alamatUsahaController.text,
        'kontak': _kontakController.text,
        'sektorUsaha': _sektorUsaha ?? '',
        'skalaUsaha': _skalaUsaha ?? '',
      };

      final result = await _service.updateProfil(
        data: formData,
        dokumenFile: _dokumenFile,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              '✅ Profil UMKM berhasil diperbarui!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        if (result['errors'] != null) {
          setState(() {
            for (String err in result['errors']) {
              if (err.toLowerCase().contains('kontak')) _kontakError = err;
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
          'Pembaruan Profil UMKM',
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
      body: _isFetching
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Loading saat ambil data lama
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Informasi Usaha'),
                    _buildTextField(
                      label: 'Nama Usaha',
                      icon: Icons.store_rounded,
                      controller: _namaUsahaController,
                    ),
                    _buildTextField(
                      label: 'Alamat Usaha',
                      icon: Icons.location_on_rounded,
                      controller: _alamatUsahaController,
                      maxLines: 2,
                    ),
                    _buildTextField(
                      label: 'Kontak/Telepon',
                      icon: Icons.phone_rounded,
                      controller: _kontakController,
                      keyboardType: TextInputType.phone,
                      errorText: _kontakError,
                    ),
                    _buildDropdown(
                      label: 'Sektor Usaha',
                      icon: Icons.category_rounded,
                      value: _sektorUsaha,
                      items: _sektorList,
                      onChanged: (val) => setState(() => _sektorUsaha = val),
                    ),
                    _buildDropdown(
                      label: 'Skala Usaha',
                      icon: Icons.bar_chart_rounded,
                      value: _skalaUsaha,
                      items: _skalaList,
                      onChanged: (val) => setState(() => _skalaUsaha = val),
                    ),

                    const SizedBox(height: 28),
                    _sectionTitle('Dokumen Pendukung'),
                    _uploadTile(
                      title: 'Upload Dokumen Pendukung (Opsional)',
                      // Logika tampilan nama: Prioritaskan file baru, lalu file lama
                      fileName: _dokumenFile?.name ?? _existingDokumen,
                      onUpload: _pickFile,
                      // Tambahkan warna hijau jika file lama terdeteksi
                      isExisting: _existingDokumen != null,
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
                                'Kirim Pembaruan',
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

  // --- UI Components (Sesuai gaya koding Anda sebelumnya) ---
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
        decoration: _inputDecoration(
          label,
          icon,
        ).copyWith(errorText: errorText),
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

  Widget _uploadTile({
    required String title,
    String? fileName,
    required VoidCallback onUpload,
    bool isExisting = false, // Parameter baru
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
            border: Border.all(
              color: isExisting ? Colors.green.shade300 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                fileName == null
                    ? Icons.upload_file_rounded
                    : Icons.check_circle_rounded,
                color: fileName == null
                    ? Colors.grey
                    : (isExisting ? Colors.blue : Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? title,
                      style: GoogleFonts.poppins(
                        color: fileName == null
                            ? Colors.grey[600]
                            : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    if (isExisting)
                      Text(
                        "(Dokumen saat ini di server)",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.blue,
                        ),
                      ),
                  ],
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
