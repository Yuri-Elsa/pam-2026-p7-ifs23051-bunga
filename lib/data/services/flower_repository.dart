// lib/data/services/flower_repository.dart

import 'dart:io';
import 'dart:typed_data';
import '../models/flower_model.dart';
import '../models/api_response_model.dart';
import 'flower_service.dart';

class FlowerRepository {
  FlowerRepository({FlowerService? service})
      : _service = service ?? FlowerService();

  final FlowerService _service;

  Future<ApiResponse<List<FlowerModel>>> getFlowers(
      {String search = ''}) async {
    try {
      return await _service.getFlowers(search: search);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Terjadi kesalahan jaringan: $e');
    }
  }

  Future<ApiResponse<FlowerModel>> getFlowerById(String id) async {
    try {
      return await _service.getFlowerById(id);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Terjadi kesalahan jaringan: $e');
    }
  }

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
    try {
      return await _service.createFlower(
        namaUmum: namaUmum,
        namaLatin: namaLatin,
        makna: makna,
        asalBudaya: asalBudaya,
        deskripsi: deskripsi,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
      );
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Terjadi kesalahan jaringan: $e');
    }
  }

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
    try {
      return await _service.updateFlower(
        id: id,
        namaUmum: namaUmum,
        namaLatin: namaLatin,
        makna: makna,
        asalBudaya: asalBudaya,
        deskripsi: deskripsi,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
      );
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Terjadi kesalahan jaringan: $e');
    }
  }

  Future<ApiResponse<void>> deleteFlower(String id) async {
    try {
      return await _service.deleteFlower(id);
    } catch (e) {
      return ApiResponse(
          success: false, message: 'Terjadi kesalahan jaringan: $e');
    }
  }
}