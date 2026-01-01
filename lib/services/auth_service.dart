import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  // Fungsi Login
  Future<String?> login(String email, String password) async {
    final url = Uri.parse(ApiConstants.login);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Debugging: Lihat apa yang dikirim server di console
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Cek apakah response berupa JSON valid
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return "Terjadi kesalahan server (Response bukan JSON)";
      }

      if (response.statusCode == 200) {
        // SUKSES
        // Pastikan backend mengirim struktur: { data: { token: "..." } }
        String token = responseData['data']['token'];
        await _saveToken(token);
        return null; // Null artinya sukses
      } else {
        // GAGAL
        if (responseData['errors'] != null &&
            (responseData['errors'] as List).isNotEmpty) {
          return responseData['errors'][0];
        }
        return responseData['message'] ?? "Terjadi kesalahan pada server";
      }
    } catch (e) {
      // PENTING: Print error asli ke console agar tahu kenapa gagal
      print("ERROR LOGIN: $e");

      // Jika error mengandung kata XMLHttpRequest (khusus Web), biasanya karena CORS
      if (e.toString().contains("XMLHttpRequest")) {
        return "Koneksi ditolak (Cek CORS Backend / Pastikan Server Nyala)";
      }

      return "Gagal terhubung ke server ($e)";
    }
  }

  // Fungsi Register
  Future<String?> register(String name, String email, String password) async {
    final url = Uri.parse(ApiConstants.register);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      print("Register Status: ${response.statusCode}");
      print("Register Body: ${response.body}");

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return "Terjadi kesalahan server (Response bukan JSON)";
      }

      if (response.statusCode == 201) {
        return null; // Sukses
      } else {
        if (responseData['errors'] != null &&
            (responseData['errors'] as List).isNotEmpty) {
          return responseData['errors'][0];
        }
        return responseData['message'] ?? "Gagal mendaftar";
      }
    } catch (e) {
      print("ERROR REGISTER: $e");
      return "Gagal terhubung ke server";
    }
  }

  // ... (Sisa fungsi token tetap sama)
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
