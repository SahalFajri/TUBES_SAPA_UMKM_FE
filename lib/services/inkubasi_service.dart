import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class InkubasiService {
  Future<Map<String, dynamic>> submitInkubasi({
    required Map<String, String> data,
    required PlatformFile? proposalFile,
    required PlatformFile? fotoUsahaFile,
  }) async {
    final uri = Uri.parse(ApiConstants.inkubasiSubmit);
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

    // Helper untuk menentukan tipe konten (Mimetype)
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

    // Attach Proposal (Wajib PDF)
    if (proposalFile != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'proposalFile',
            proposalFile.bytes!,
            filename: proposalFile.name,
            contentType: getContentType(proposalFile.name),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'proposalFile',
            proposalFile.path!,
            contentType: getContentType(proposalFile.name),
          ),
        );
      }
    }

    // Attach Foto Usaha (Wajib Gambar)
    if (fotoUsahaFile != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'fotoUsahaFile',
            fotoUsahaFile.bytes!,
            filename: fotoUsahaFile.name,
            contentType: getContentType(fotoUsahaFile.name),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'fotoUsahaFile',
            fotoUsahaFile.path!,
            contentType: getContentType(fotoUsahaFile.name),
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
        return {
          "success": false,
          "message": jsonResponse['message'] ?? "Gagal mengirim data",
          "errors":
              jsonResponse['errors'], // Untuk menangkap validasi PDF/Gambar dari backend
        };
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  Future<List<dynamic>> getHistory() async {
    final uri = Uri.parse(ApiConstants.inkubasiHistory);
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
        throw Exception("Gagal memuat riwayat pendaftaran");
      }
    } catch (e) {
      throw Exception("Kesalahan koneksi: $e");
    }
  }
}
