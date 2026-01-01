import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class ForumService {
  // 1. Mengambil semua daftar topik diskusi
  Future<List<dynamic>> getTopics() async {
    final uri = Uri.parse(
      ApiConstants.forumList,
    ); // Pastikan ini ada di api_constants.dart

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
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      } else {
        throw Exception("Gagal memuat daftar forum");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // 2. Membuat topik diskusi baru (POST)
  Future<Map<String, dynamic>> createTopic(String title) async {
    final uri = Uri.parse(ApiConstants.forumCreate);

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
        },
        body: jsonEncode({'title': title}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "data": jsonResponse['data']};
      } else {
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
          "message": jsonResponse['message'] ?? "Gagal membuat topik",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // 3. Mengambil detail topik dan komentar (GET dengan ID)
  Future<Map<String, dynamic>> getTopicDetail(int id) async {
    final uri = Uri.parse("${ApiConstants.forumDetail}/$id");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) throw Exception("Sesi habis.");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse['data'];
      } else {
        throw Exception(jsonResponse['message'] ?? "Gagal memuat detail forum");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // 4. Menambahkan komentar (POST)
  Future<Map<String, dynamic>> addComment(int topicId, String content) async {
    final uri = Uri.parse(ApiConstants.forumAddComment);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) return {"success": false, "message": "Sesi habis."};

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'forumTopicId': topicId, 'content': content}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "data": jsonResponse['data']};
      } else {
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
          "message": jsonResponse['message'] ?? "Gagal mengirim komentar",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }
}
