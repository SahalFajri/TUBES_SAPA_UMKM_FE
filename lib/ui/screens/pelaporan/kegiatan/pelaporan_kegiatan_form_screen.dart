import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/pelaporan_kegiatan_service.dart';

class PelaporanKegiatanFormScreen extends StatefulWidget {
  const PelaporanKegiatanFormScreen({super.key});

  @override
  State<PelaporanKegiatanFormScreen> createState() =>
      _PelaporanKegiatanFormScreenState();
}

class _PelaporanKegiatanFormScreenState
    extends State<PelaporanKegiatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PelaporanKegiatanService _service = PelaporanKegiatanService();
  bool _isLoading = false;

  // Controllers
  final _namaUsahaController = TextEditingController();
  final _periodeController = TextEditingController();
  final _omzetController = TextEditingController();
  final _kendalaController = TextEditingController();
  final _rencanaController = TextEditingController();

  // Dropdown values
  String? _perkembangan;
  String? _jenisLaporan;

  // Real upload file
  PlatformFile? _dokumenFile;

  // Error states for backend validation
  String? _omzetError;
  String? _rencanaError;

  final List<String> _perkembanganList = ['Meningkat', 'Stabil', 'Menurun'];

  final List<String> _jenisLaporanList = [
    'Laporan Bulanan',
    'Laporan Triwulan',
    'Laporan Tahunan',
  ];

  // Fungsi Pilih File Asli
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _dokumenFile = result.files.first;
      });
    }
  }

  void _resetErrors() {
    setState(() {
      _omzetError = null;
      _rencanaError = null;
    });
  }

  void _submitForm() async {
    _resetErrors();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Mapping data sesuai field backend
      Map<String, String> formData = {
        'namaUsaha': _namaUsahaController.text,
        'periode': _periodeController.text,
        'jenisLaporan': _jenisLaporan ?? '',
        'perkembangan': _perkembangan ?? '',
        'omzet': _omzetController.text,
        'kendala': _kendalaController.text,
        'rencana': _rencanaController.text,
      };

      final result = await _service.submitPelaporan(
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
              '✅ Laporan kegiatan berhasil dikirim!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        // Tangkap error spesifik dari backend (misal: omzet bukan angka)
        if (result['errors'] != null) {
          setState(() {
            for (String err in result['errors']) {
              if (err.toLowerCase().contains('omzet')) _omzetError = err;
              if (err.toLowerCase().contains('rencana')) _rencanaError = err;
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                '❌ ${result['message'] ?? "Gagal mengirim laporan"}',
              ),
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
          'Pelaporan Kegiatan Usaha',
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
              _sectionTitle('Data Usaha'),
              _buildTextField(
                label: 'Nama Usaha',
                icon: Icons.store_rounded,
                controller: _namaUsahaController,
              ),
              _buildTextField(
                label: 'Periode Pelaporan (mis. Januari 2025)',
                icon: Icons.date_range_rounded,
                controller: _periodeController,
              ),
              _buildDropdown(
                label: 'Jenis Laporan',
                icon: Icons.assignment_rounded,
                value: _jenisLaporan,
                items: _jenisLaporanList,
                onChanged: (val) => setState(() => _jenisLaporan = val),
              ),
              _buildDropdown(
                label: 'Perkembangan Usaha',
                icon: Icons.trending_up_rounded,
                value: _perkembangan,
                items: _perkembanganList,
                onChanged: (val) => setState(() => _perkembangan = val),
              ),
              _buildTextField(
                label: 'Total Omzet (Rp)',
                icon: Icons.attach_money_rounded,
                controller: _omzetController,
                keyboardType: TextInputType.number,
                errorText: _omzetError,
              ),

              const SizedBox(height: 28),
              _sectionTitle('Keterangan Tambahan'),
              _buildTextField(
                label: 'Kendala Usaha (Opsional)',
                icon: Icons.warning_rounded,
                controller: _kendalaController,
                maxLines: 3,
                isMandatory: false,
              ),
              _buildTextField(
                label: 'Rencana Pengembangan Usaha',
                icon: Icons.lightbulb_rounded,
                controller: _rencanaController,
                maxLines: 3,
                errorText: _rencanaError,
              ),

              const SizedBox(height: 28),
              _sectionTitle('Dokumen Pendukung'),
              _uploadTile(
                title: 'Upload Dokumen Pendukung (Opsional)',
                fileName: _dokumenFile?.name,
                onUpload: _pickFile,
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
                          'Kirim Laporan',
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

  // 🔹 COMPONENTS
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
    bool isMandatory = true,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isMandatory && (value == null || value.isEmpty)) {
            return '$label wajib diisi';
          }
          return null;
        },
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
