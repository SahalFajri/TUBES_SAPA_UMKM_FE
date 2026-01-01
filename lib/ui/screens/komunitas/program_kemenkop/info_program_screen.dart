import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/kemenkop_program_service.dart';

class InfoProgramScreen extends StatefulWidget {
  const InfoProgramScreen({super.key});

  @override
  State<InfoProgramScreen> createState() => _InfoProgramScreenState();
}

class _InfoProgramScreenState extends State<InfoProgramScreen> {
  final KemenkopProgramService _programService = KemenkopProgramService();
  List<dynamic> _programs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrograms();
  }

  Future<void> _fetchPrograms() async {
    setState(() => _isLoading = true);
    try {
      final data = await _programService.getPrograms();
      setState(() {
        _programs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Gagal memuat informasi program: $e", isError: true);
    }
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar("Tidak dapat membuka tautan", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : AppColors.primary,
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Info Program KemenKopUKM',
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
      body: RefreshIndicator(
        onRefresh: _fetchPrograms,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _programs.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _programs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _programs[index];
                  return InkWell(
                    onTap: () => _launchURL(item['link']),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['title'] ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.open_in_new_rounded,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['description'] ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          if (item['link'] != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Klik untuk info selengkapnya',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Tidak ada informasi program saat ini.',
        style: GoogleFonts.poppins(color: Colors.grey),
      ),
    );
  }
}
