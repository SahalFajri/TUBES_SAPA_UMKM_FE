import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class SertifikasiService {
  // Method Submit: Mengikuti pola submit sebelumnya
  Future<Map<String, dynamic>> submitSertifikasi({
    required Map<String, String> data,
    required PlatformFile? fotoProduk,
    required PlatformFile? dokumenPersyaratan,
  }) async {
    final uri = Uri.parse(ApiConstants.sertifikasiSubmit);
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

    // Attach File: Foto Produk
    if (fotoProduk != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'fotoProduk',
            fotoProduk.bytes!,
            filename: fotoProduk.name,
            contentType: getContentType(fotoProduk.name),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'fotoProduk',
            fotoProduk.path!,
            contentType: getContentType(fotoProduk.name),
          ),
        );
      }
    }

    // Attach File: Dokumen Persyaratan
    if (dokumenPersyaratan != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'dokumenPersyaratan',
            dokumenPersyaratan.bytes!,
            filename: dokumenPersyaratan.name,
            contentType: getContentType(dokumenPersyaratan.name),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'dokumenPersyaratan',
            dokumenPersyaratan.path!,
            contentType: getContentType(dokumenPersyaratan.name),
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
        // Handle error list dari backend
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

  // Method History: Mengikuti pola getHistory sebelumnya
  Future<List<dynamic>> getHistory() async {
    final uri = Uri.parse(ApiConstants.sertifikasiHistory);

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
        throw Exception("Gagal memuat data");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
