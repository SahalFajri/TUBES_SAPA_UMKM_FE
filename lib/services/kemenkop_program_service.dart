import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class KemenkopProgramService {
  // Method untuk mengambil daftar program resmi dari Kemenkop
  Future<List<dynamic>> getPrograms() async {
    final uri = Uri.parse(ApiConstants.kemenkopProgramList);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("Sesi habis, silakan login kembali.");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Mengembalikan list data dari key 'data' sesuai respon backend
        return jsonResponse['data'];
      } else {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? "Gagal memuat info program");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }
}
