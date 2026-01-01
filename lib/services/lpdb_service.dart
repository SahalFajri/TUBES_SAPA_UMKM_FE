import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class LpdbService {
  // 1. Method untuk Mengirim Pengajuan LPDB
  Future<Map<String, dynamic>> submitLpdb({
    required Map<String, String> data,
    required PlatformFile? ktpFile,
    PlatformFile? skuFile,
  }) async {
    final uri = Uri.parse(ApiConstants.lpdbSubmit);
    var request = http.MultipartRequest('POST', uri);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      return {
        "success": false,
        "message": "Sesi habis, silakan login kembali.",
      };
    }

    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.fields.addAll(data);

    // Helper untuk menentukan tipe konten file
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

    // Attach File: Foto E-KTP (Wajib)
    if (ktpFile != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'ktpFile',
            ktpFile.bytes!,
            filename: ktpFile.name,
            contentType: getContentType(ktpFile.name),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'ktpFile',
            ktpFile.path!,
            contentType: getContentType(ktpFile.name),
          ),
        );
      }
    }

    // Attach File: SKU (Opsional)
    if (skuFile != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'skuFile',
            skuFile.bytes!,
            filename: skuFile.name,
            contentType: getContentType(skuFile.name),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'skuFile',
            skuFile.path!,
            contentType: getContentType(skuFile.name),
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
        // Mengembalikan daftar error validasi jika ada (untuk inline validation)
        return {
          "success": false,
          "message": jsonResponse['message'] ?? "Gagal mengirim data",
          "errors": jsonResponse['errors'],
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // 2. Method untuk Mengambil Riwayat Pengajuan LPDB
  Future<List<dynamic>> getHistory() async {
    final uri = Uri.parse(ApiConstants.lpdbHistory);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) throw Exception("Sesi habis, silakan login kembali.");

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
        throw Exception("Gagal memuat data riwayat");
      }
    } catch (e) {
      throw Exception("Kesalahan koneksi: $e");
    }
  }
}
