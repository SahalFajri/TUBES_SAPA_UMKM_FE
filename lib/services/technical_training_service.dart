import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class TechnicalTrainingService {
  // 1. Ambil Daftar Pelatihan Teknis & Manajemen
  Future<List<dynamic>> getTrainings() async {
    final uri = Uri.parse(ApiConstants.pelatihanTeknisList);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) throw Exception("Sesi habis, silakan login kembali.");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse['data']; // Mengembalikan list pelatihan + isFull + currentRegistrations
      } else {
        throw Exception(
          jsonResponse['message'] ?? "Gagal memuat pelatihan teknis",
        );
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // 2. Daftar Pelatihan Teknis (POST)
  Future<Map<String, dynamic>> registerTraining(int trainingId) async {
    final uri = Uri.parse(ApiConstants.pelatihanTeknisDaftar);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) return {"success": false, "message": "Sesi habis."};

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'technicalTrainingId': trainingId}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "message": jsonResponse['message']};
      } else {
        // Menangani error jika kuota penuh atau sudah terdaftar (400 Bad Request)
        return {
          "success": false,
          "message": jsonResponse['message'] ?? "Gagal mendaftar",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }
}
