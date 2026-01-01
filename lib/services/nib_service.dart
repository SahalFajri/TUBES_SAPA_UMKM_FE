import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class NibService {
  // Ubah return type jadi Map<String, dynamic> agar bisa kirim status & list error
  Future<Map<String, dynamic>> submitNib({
    required Map<String, String> data,
    required PlatformFile? fotoKtp,
    PlatformFile? skdFile,
  }) async {
    final uri = Uri.parse(ApiConstants.nibSubmit);
    var request = http.MultipartRequest('POST', uri);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null)
      return {
        "success": false,
        "message": "Sesi habis, silakan login kembali.",
      };

    request.headers.addAll({'Authorization': 'Bearer $token'});

    request.fields.addAll(data);

    // Helper tipe file
    MediaType getContentType(String filename) {
      if (filename.toLowerCase().endsWith('.pdf'))
        return MediaType('application', 'pdf');
      if (filename.toLowerCase().endsWith('.jpg') ||
          filename.toLowerCase().endsWith('.jpeg'))
        return MediaType('image', 'jpeg');
      if (filename.toLowerCase().endsWith('.png'))
        return MediaType('image', 'png');
      return MediaType('application', 'octet-stream');
    }

    // Attach Files
    if (fotoKtp != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'fotoKtp',
            fotoKtp.bytes!,
            filename: fotoKtp.name,
            contentType: getContentType(fotoKtp.name),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'fotoKtp',
            fotoKtp.path!,
            contentType: getContentType(fotoKtp.name),
          ),
        );
      }
    }

    if (skdFile != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'skdFile',
            skdFile.bytes!,
            filename: skdFile.name,
            contentType: getContentType(skdFile.name),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'skdFile',
            skdFile.path!,
            contentType: getContentType(skdFile.name),
          ),
        );
      }
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var jsonResponse = jsonDecode(response.body);

      // --- LOGIKA BARU UNTUK HANDLE ERROR LIST ---
      if (response.statusCode == 201) {
        return {"success": true};
      } else {
        // Jika ada array 'errors' (dari express-validator backend kamu)
        if (jsonResponse['errors'] != null &&
            (jsonResponse['errors'] as List).isNotEmpty) {
          return {
            "success": false,
            "message": "Validasi Gagal",
            "errors":
                jsonResponse['errors'], // Kembalikan list error: ["NIK salah", "Nama kosong"]
          };
        }
        // Jika error umum
        return {
          "success": false,
          "message": jsonResponse['message'] ?? "Gagal mengirim data",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  Future<List<dynamic>> getHistory() async {
    final uri = Uri.parse(ApiConstants.nibHistory);

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
        // Asumsi respons backend: { status: 'success', data: [...] }
        return jsonResponse['data'];
      } else {
        throw Exception("Gagal memuat data");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
