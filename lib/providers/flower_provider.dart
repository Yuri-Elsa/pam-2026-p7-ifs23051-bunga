// lib/providers/flower_provider.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../data/models/flower_model.dart';
import '../data/services/flower_repository.dart';

enum FlowerStatus { initial, loading, success, error }

class FlowerProvider extends ChangeNotifier {
  FlowerProvider({FlowerRepository? repository})
      : _repository = repository ?? FlowerRepository();

  final FlowerRepository _repository;

  FlowerStatus _status = FlowerStatus.initial;
  List<FlowerModel> _flowers = [];
  FlowerModel? _selectedFlower;
  String _errorMessage = '';
  String _searchQuery = '';

  FlowerStatus get status => _status;
  FlowerModel? get selectedFlower => _selectedFlower;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<FlowerModel> get flowers {
    if (_searchQuery.isEmpty) return List.unmodifiable(_flowers);
    final q = _searchQuery.toLowerCase();
    return _flowers
        .where((f) =>
    f.namaUmum.toLowerCase().contains(q) ||
        f.namaLatin.toLowerCase().contains(q) ||
        f.makna.toLowerCase().contains(q))
        .toList();
  }

  Future<void> loadFlowers() async {
    _setStatus(FlowerStatus.loading);
    final result = await _repository.getFlowers();
    if (result.success && result.data != null) {
      _flowers = result.data!;
      _setStatus(FlowerStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(FlowerStatus.error);
    }
  }

  Future<void> loadFlowerById(String id) async {
    _setStatus(FlowerStatus.loading);
    final result = await _repository.getFlowerById(id);
    if (result.success && result.data != null) {
      _selectedFlower = result.data;
      _setStatus(FlowerStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(FlowerStatus.error);
    }
  }

  Future<bool> addFlower({
    required String namaUmum,
    required String namaLatin,
    required String makna,
    required String asalBudaya,
    required String deskripsi,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFilename = 'image.jpg',
  }) async {
    _setStatus(FlowerStatus.loading);
    final result = await _repository.createFlower(
      namaUmum: namaUmum,
      namaLatin: namaLatin,
      makna: makna,
      asalBudaya: asalBudaya,
      deskripsi: deskripsi,
      imageFile: imageFile,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
    );
    if (result.success) {
      await loadFlowers();
      return true;
    }
    _errorMessage = result.message;
    _setStatus(FlowerStatus.error);
    return false;
  }

  Future<bool> editFlower({
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
    _setStatus(FlowerStatus.loading);
    final result = await _repository.updateFlower(
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
    if (result.success) {
      await loadFlowerById(id);
      return true;
    }
    _errorMessage = result.message;
    _setStatus(FlowerStatus.error);
    return false;
  }

  Future<bool> removeFlower(String id) async {
    _setStatus(FlowerStatus.loading);
    final result = await _repository.deleteFlower(id);
    if (result.success) {
      _flowers.removeWhere((f) => f.id == id);
      _setStatus(FlowerStatus.success);
      return true;
    }
    _errorMessage = result.message;
    _setStatus(FlowerStatus.error);
    return false;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSelectedFlower() {
    _selectedFlower = null;
    notifyListeners();
  }

  void _setStatus(FlowerStatus status) {
    _status = status;
    notifyListeners();
  }
}