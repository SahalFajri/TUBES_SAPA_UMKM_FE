import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class ProfilUmkmService {
  // Method Update Profil (Multipart POST)
  Future<Map<String, dynamic>> updateProfil({
    required Map<String, String> data,
    PlatformFile? dokumenFile,
  }) async {
    final uri = Uri.parse(ApiConstants.profilUpdate); // Menggunakan Constant
    var request = http.MultipartRequest('POST', uri);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      return {
        "success": false,
        "message": "Sesi habis, silakan login kembali.",
      };
    }

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll(data);

    // Helper untuk menentukan tipe file
    MediaType getContentType(String filename) {
      final name = filename.toLowerCase();
      if (name.endsWith('.pdf')) return MediaType('application', 'pdf');
      if (name.endsWith('.jpg') || name.endsWith('.jpeg'))
        return MediaType('image', 'jpeg');
      if (name.endsWith('.png')) return MediaType('image', 'png');
      return MediaType('application', 'octet-stream');
    }

    // Penanganan File
    if (dokumenFile != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'dokumenFile',
            dokumenFile.bytes!,
            filename: dokumenFile.name,
            contentType: getContentType(dokumenFile.name),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'dokumenFile',
            dokumenFile.path!,
            contentType: getContentType(dokumenFile.name),
          ),
        );
      }
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"success": true};
      } else {
        // Handle Validation Errors dari Backend
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
          "message": jsonResponse['message'] ?? "Gagal memperbarui profil",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // Method Ambil Data Terbaru (Auto-fill)
  Future<Map<String, dynamic>?> getLatestProfile() async {
    final uri = Uri.parse(ApiConstants.profilLatest); // Menggunakan Constant

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) return null;

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }
}
