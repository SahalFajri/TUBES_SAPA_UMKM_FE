import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../../services/user_service.dart'; // Panggil Service Baru

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService(); // Pakai UserService

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  String joinedDate = "-"; // Variabel untuk nampung tanggal gabung
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final userData = await _userService.getProfile();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (userData != null) {
          nameController.text = userData['name'];
          emailController.text = userData['email'];

          // Parsing tanggal biar cantik (Opsional)
          // Dari "2024-12-23T10:00:00Z" jadi ambil depannya aja
          if (userData['createdAt'] != null) {
            joinedDate = userData['createdAt'].toString().substring(0, 10);
          }
        }
      });
    }
  }

  void _handleUpdate() async {
    setState(() => _isSaving = true);

    // Panggil fungsi update di UserService
    String? error = await _userService.updateProfile(
      nameController.text,
      emailController.text,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil Berhasil Diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Edit Profil",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Info Tanggal Gabung
                  Text(
                    "Bergabung sejak: $joinedDate",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form
                  CustomTextField(
                    label: "Nama Lengkap",
                    icon: Icons.person_outline,
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Email",
                    icon: Icons.email_outlined,
                    controller: emailController,
                  ),

                  const SizedBox(height: 40),

                  CustomButton(
                    text: _isSaving ? "Menyimpan..." : "Simpan Perubahan",
                    onPressed: _isSaving ? null : _handleUpdate,
                  ),
                ],
              ),
            ),
    );
  }
}
