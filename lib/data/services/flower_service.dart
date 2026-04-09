// lib/data/services/flower_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/flower_model.dart';
import '../models/api_response_model.dart';
import '../../core/constants/api_constants.dart';

class FlowerService {
  FlowerService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ApiResponse<List<FlowerModel>>> getFlowers({String search = ''}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.flowers}')
        .replace(queryParameters: search.isNotEmpty ? {'search': search} : null);

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = body['data'] as Map<String, dynamic>;
      final List<dynamic> jsonList = dataMap['flowers'] as List<dynamic>;
      final flowers = jsonList
          .map((e) => FlowerModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: true,
        message: body['message'] as String? ?? 'Berhasil.',
        data: flowers,
      );
    }

    return ApiResponse(success: false, message: _parseErrorMessage(response));
  }

  Future<ApiResponse<FlowerModel>> getFlowerById(String id) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.flowerById(id)}');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = body['data'] as Map<String, dynamic>;
      final flower =
      FlowerModel.fromJson(dataMap['flower'] as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        message: body['message'] as String? ?? 'Berhasil.',
        data: flower,
      );
    }

    return ApiResponse(success: false, message: _parseErrorMessage(response));
  }

  // POST /flowers — multipart/form-data
  Future<ApiResponse<String>> createFlower({
    required String namaUmum,
    required String namaLatin,
    required String makna,
    required String asalBudaya,
    required String deskripsi,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFilename = 'image.jpg',
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.flowers}');

    final request = http.MultipartRequest('POST', uri)
      ..fields['namaUmum'] = namaUmum
      ..fields['namaLatin'] = namaLatin
      ..fields['makna'] = makna
      ..fields['asalBudaya'] = asalBudaya
      ..fields['deskripsi'] = deskripsi;

    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file', imageBytes,
        filename: imageFilename,
      ));
    } else if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = body['data'] as Map<String, dynamic>;
      return ApiResponse(
        success: true,
        message: body['message'] as String? ?? 'Bunga berhasil ditambahkan.',
        data: dataMap['flowerId'] as String,
      );
    }

    return ApiResponse(success: false, message: _parseErrorMessage(response));
  }

  // PUT /flowers/:id — multipart/form-data
  Future<ApiResponse<void>> updateFlower({
    required String id,
    required String namaUmum,
    required String namaLatin,
    required String makna,
    required String asalBudaya,
    required String deskripsi,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFilename = 'image.jpg',
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.flowerById(id)}');

    final request = http.MultipartRequest('PUT', uri)
      ..fields['namaUmum'] = namaUmum
      ..fields['namaLatin'] = namaLatin
      ..fields['makna'] = makna
      ..fields['asalBudaya'] = asalBudaya
      ..fields['deskripsi'] = deskripsi;

    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file', imageBytes,
        filename: imageFilename,
      ));
    } else if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse(
        success: true,
        message:
        body['message'] as String? ?? 'Bunga berhasil diperbarui.',
      );
    }

    return ApiResponse(success: false, message: _parseErrorMessage(response));
  }

  Future<ApiResponse<void>> deleteFlower(String id) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.flowerById(id)}');
    final response = await _client.delete(uri);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return const ApiResponse(
          success: true, message: 'Bunga berhasil dihapus.');
    }

    return ApiResponse(success: false, message: _parseErrorMessage(response));
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ?? 'Gagal. Kode: ${response.statusCode}';
    } catch (_) {
      return 'Gagal. Kode: ${response.statusCode}';
    }
  }

  void dispose() => _client.close();
}