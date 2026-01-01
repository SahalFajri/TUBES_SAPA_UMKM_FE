import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class UmiService {
  Future<Map<String, dynamic>> submitUmi({
    required Map<String, String> data,
    required PlatformFile? ktpFile,
    PlatformFile? skuFile,
  }) async {
    final uri = Uri.parse(ApiConstants.umiSubmit);
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

    MediaType getContentType(String filename) {
      if (filename.toLowerCase().endsWith('.pdf'))
        return MediaType('application', 'pdf');
      if (filename.toLowerCase().endsWith('.jpg') ||
          filename.toLowerCase().endsWith('.jpeg'))
        return MediaType('image', 'jpeg');
      return MediaType('image', 'png');
    }

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

      if (response.statusCode == 201) return {"success": true};
      return {
        "success": false,
        "message": jsonResponse['message'] ?? "Gagal mengirim data",
        "errors": jsonResponse['errors'],
      };
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  Future<List<dynamic>> getHistory() async {
    final uri = Uri.parse(ApiConstants.umiHistory);
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
      if (response.statusCode == 200) return jsonDecode(response.body)['data'];
      throw Exception("Gagal memuat riwayat UMi");
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
