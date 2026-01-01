import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class KomunitasPelatihanService {
  // 1. Mengambil daftar pelatihan komunitas yang tersedia (untuk Dropdown)
  Future<List<dynamic>> getListPelatihan() async {
    final uri = Uri.parse(ApiConstants.komunitasPelatihanList);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login.");
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
        return jsonResponse['data'];
      } else {
        throw Exception("Gagal memuat daftar pelatihan komunitas");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // 2. Mendaftar pelatihan komunitas (POST)
  Future<Map<String, dynamic>> daftarPelatihan({
    required int trainingId,
    required String namaLengkap,
    required String email,
    required String noHp,
  }) async {
    final uri = Uri.parse(ApiConstants.komunitasPelatihanDaftar);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      return {
        "success": false,
        "message": "Sesi habis, silakan login kembali.",
      };
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'trainingId': trainingId,
          'namaLengkap': namaLengkap,
          'email': email,
          'noHp': noHp,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "message": "Pendaftaran berhasil dikirim"};
      } else {
        // Handle Validation Errors dari Backend (Joi/express-validator)
        if (jsonResponse['errors'] != null &&
            (jsonResponse['errors'] as List).isNotEmpty) {
          return {
            "success": false,
            "message": "Validasi Gagal",
            "errors": jsonResponse['errors'],
          };
        }
        return {
          "success": false,
          "message": jsonResponse['message'] ?? "Gagal melakukan pendaftaran",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }
}
