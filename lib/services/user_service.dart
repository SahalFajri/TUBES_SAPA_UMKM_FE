import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'auth_service.dart'; // Kita butuh ini untuk ambil Token

class UserService {
  final AuthService _authService = AuthService();

  // 1. Ambil Profil (GET)
  Future<Map<String, dynamic>?> getProfile() async {
    // Ambil token dari memori HP
    String? token = await _authService.getToken();

    // URL endpoint baru yang kita buat tadi
    // Pastikan di ApiConstants sudah ada: static String userProfile = "$baseUrl/users/me";
    // Kalau belum, pakai string manual dulu:
    final url = Uri.parse("${ApiConstants.baseUrl}/users/me");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // PENTING: Bawa token!
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // {id: 1, name: "...", email: "...", createdAt: "..."}
      }
      return null;
    } catch (e) {
      print("Error Get Profile: $e");
      return null;
    }
  }

  // 2. Update Profil (PUT)
  Future<String?> updateProfile(String name, String email) async {
    String? token = await _authService.getToken();
    final url = Uri.parse("${ApiConstants.baseUrl}/users/me");

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return null; // Sukses
      } else {
        return data['message'] ?? "Gagal update profil";
      }
    } catch (e) {
      return "Koneksi Error: $e";
    }
  }
}
