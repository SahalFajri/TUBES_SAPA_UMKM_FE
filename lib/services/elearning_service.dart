import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class ELearningService {
  // Ambil Daftar Modul E-Learning Mandiri
  Future<List<dynamic>> getModules() async {
    final uri = Uri.parse(ApiConstants.elearningModulList);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) throw Exception("Sesi habis.");

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
        return jsonResponse['data'];
      } else {
        throw Exception(jsonResponse['message'] ?? "Gagal memuat modul");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
