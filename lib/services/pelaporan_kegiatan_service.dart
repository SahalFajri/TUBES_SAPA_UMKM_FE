import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class PelaporanKegiatanService {
  Future<Map<String, dynamic>> submitPelaporan({
    required Map<String, String> data,
    PlatformFile? dokumenFile,
  }) async {
    final uri = Uri.parse(ApiConstants.pelaporanSubmit);
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

    // Helper tipe file sesuai standar NibService kamu
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

    // Attach File (Opsional)
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

      if (response.statusCode == 201) {
        return {"success": true};
      } else {
        // Menggunakan logic handle error list sesuai NibService kamu
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
          "message": jsonResponse['message'] ?? "Gagal mengirim data",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  Future<List<dynamic>> getHistory() async {
    final uri = Uri.parse(ApiConstants.pelaporanHistory);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception("Gagal memuat data");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
