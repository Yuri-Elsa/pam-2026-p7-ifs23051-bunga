// test/unit/flower_provider_test.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p7_2026_ifs23051/data/models/api_response_model.dart';
import 'package:pam_p7_2026_ifs23051/data/models/flower_model.dart';
import 'package:pam_p7_2026_ifs23051/data/services/flower_repository.dart';
import 'package:pam_p7_2026_ifs23051/providers/flower_provider.dart';

/// Repository palsu (mock) untuk keperluan pengujian
/// Tidak melakukan HTTP request sungguhan
class MockFlowerRepository extends FlowerRepository {
  MockFlowerRepository({
    required this.mockFlowers,
    this.shouldFail = false,
  });

  final List<FlowerModel> mockFlowers;
  final bool shouldFail;

  @override
  Future<ApiResponse<List<FlowerModel>>> getFlowers({String search = ''}) async {
    if (shouldFail) {
      return const ApiResponse(
        success: false,
        message: 'Gagal terhubung ke server.',
      );
    }
    return ApiResponse(success: true, message: 'OK', data: mockFlowers);
  }

  @override
  Future<ApiResponse<FlowerModel>> getFlowerById(String id) async {
    if (shouldFail) {
      return const ApiResponse(
        success: false,
        message: 'Gagal memuat data bunga.',
      );
    }
    final flower = mockFlowers.firstWhere(
          (f) => f.id == id,
      orElse: () => mockFlowers.first,
    );
    return ApiResponse(success: true, message: 'OK', data: flower);
  }

  @override
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
    if (shouldFail) {
      return const ApiResponse(
        success: false,
        message: 'Gagal menambahkan data bunga.',
      );
    }
    return const ApiResponse(
      success: true,
      message: 'OK',
      data: 'new-flower-uuid-1234',
    );
  }

  @override
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
    if (shouldFail) {
      return const ApiResponse(
        success: false,
        message: 'Gagal memperbarui data bunga.',
      );
    }
    return const ApiResponse(success: true, message: 'OK');
  }

  @override
  Future<ApiResponse<void>> deleteFlower(String id) async {
    if (shouldFail) {
      return const ApiResponse(
        success: false,
        message: 'Gagal menghapus data bunga.',
      );
    }
    return const ApiResponse(success: true, message: 'OK');
  }
}

void main() {
  const testFlowers = [
    FlowerModel(
      id: 'uuid-mawar',
      namaUmum: 'Mawar',
      namaLatin: 'Rosa',
      makna: 'Cinta',
      asalBudaya: 'Eropa',
      deskripsi: 'Bunga merah nan indah.',
      gambar: 'https://host/static/flowers/mawar.png',
    ),
    FlowerModel(
      id: 'uuid-melati',
      namaUmum: 'Melati',
      namaLatin: 'Jasminum sambac',
      makna: 'Kesucian',
      asalBudaya: 'Asia Selatan',
      deskripsi: 'Bunga putih harum khas Indonesia.',
      gambar: 'https://host/static/flowers/melati.png',
    ),
  ];

  group('FlowerProvider', () {
    late FlowerProvider provider;

    setUp(() {
      provider = FlowerProvider(
        repository: MockFlowerRepository(mockFlowers: testFlowers),
      );
    });

    tearDown(() {
      provider.dispose();
    });

    // ── Status awal ────────────────────────────────────────────────────────

    test('status awal adalah initial', () {
      expect(provider.status, equals(FlowerStatus.initial));
    });

    test('flowers awal adalah list kosong', () {
      expect(provider.flowers, isEmpty);
    });

    test('errorMessage awal adalah string kosong', () {
      expect(provider.errorMessage, equals(''));
    });

    test('searchQuery awal adalah string kosong', () {
      expect(provider.searchQuery, equals(''));
    });

    test('selectedFlower awal adalah null', () {
      expect(provider.selectedFlower, isNull);
    });

    // ── loadFlowers ────────────────────────────────────────────────────────

    test('loadFlowers berhasil mengubah status ke success', () async {
      await provider.loadFlowers();

      expect(provider.status, equals(FlowerStatus.success));
      expect(provider.flowers.length, equals(2));
    });

    test('loadFlowers berhasil mengisi daftar bunga', () async {
      await provider.loadFlowers();

      expect(provider.flowers.any((f) => f.namaUmum == 'Mawar'), isTrue);
      expect(provider.flowers.any((f) => f.namaUmum == 'Melati'), isTrue);
    });

    test('loadFlowers gagal mengubah status ke error', () async {
      provider = FlowerProvider(
        repository: MockFlowerRepository(mockFlowers: [], shouldFail: true),
      );

      await provider.loadFlowers();

      expect(provider.status, equals(FlowerStatus.error));
      expect(provider.errorMessage, isNotEmpty);
    });

    // ── loadFlowerById ─────────────────────────────────────────────────────

    test('loadFlowerById berhasil mengisi selectedFlower', () async {
      await provider.loadFlowerById('uuid-mawar');

      expect(provider.selectedFlower, isNotNull);
      expect(provider.selectedFlower!.namaUmum, equals('Mawar'));
    });

    test('loadFlowerById gagal mengubah status ke error', () async {
      provider = FlowerProvider(
        repository: MockFlowerRepository(
          mockFlowers: testFlowers,
          shouldFail: true,
        ),
      );

      await provider.loadFlowerById('uuid-mawar');

      expect(provider.status, equals(FlowerStatus.error));
      expect(provider.errorMessage, isNotEmpty);
    });

    // ── Search ─────────────────────────────────────────────────────────────

    test('updateSearchQuery memfilter berdasarkan namaUmum', () async {
      await provider.loadFlowers();
      provider.updateSearchQuery('mawar');

      expect(provider.flowers.length, equals(1));
      expect(provider.flowers.first.namaUmum, equals('Mawar'));
    });

    test('updateSearchQuery memfilter berdasarkan namaLatin', () async {
      await provider.loadFlowers();
      provider.updateSearchQuery('jasminum');

      expect(provider.flowers.length, equals(1));
      expect(provider.flowers.first.namaUmum, equals('Melati'));
    });

    test('updateSearchQuery memfilter berdasarkan makna', () async {
      await provider.loadFlowers();
      provider.updateSearchQuery('kesucian');

      expect(provider.flowers.length, equals(1));
      expect(provider.flowers.first.namaUmum, equals('Melati'));
    });

    test('updateSearchQuery kosong menampilkan semua bunga', () async {
      await provider.loadFlowers();
      provider.updateSearchQuery('mawar');
      provider.updateSearchQuery('');

      expect(provider.flowers.length, equals(2));
    });

    test('updateSearchQuery tidak sensitif huruf besar/kecil', () async {
      await provider.loadFlowers();
      provider.updateSearchQuery('MAWAR');

      expect(provider.flowers.length, equals(1));
    });

    test('updateSearchQuery dengan kata tidak cocok menghasilkan list kosong',
            () async {
          await provider.loadFlowers();
          provider.updateSearchQuery('xyznotfound');

          expect(provider.flowers, isEmpty);
        });

    // ── addFlower ──────────────────────────────────────────────────────────

    test('addFlower berhasil mengembalikan true', () async {
      final result = await provider.addFlower(
        namaUmum: 'Anggrek',
        namaLatin: 'Orchidaceae',
        makna: 'Keindahan',
        asalBudaya: 'Asia Tropis',
        deskripsi: 'Bunga eksotis dengan beragam warna.',
      );

      expect(result, isTrue);
    });

    test('addFlower gagal mengembalikan false dan mengisi errorMessage',
            () async {
          provider = FlowerProvider(
            repository: MockFlowerRepository(
              mockFlowers: testFlowers,
              shouldFail: true,
            ),
          );

          final result = await provider.addFlower(
            namaUmum: 'Anggrek',
            namaLatin: 'Orchidaceae',
            makna: 'Keindahan',
            asalBudaya: 'Asia Tropis',
            deskripsi: 'Bunga eksotis.',
          );

          expect(result, isFalse);
          expect(provider.errorMessage, isNotEmpty);
        });

    // ── editFlower ─────────────────────────────────────────────────────────

    test('editFlower berhasil mengembalikan true', () async {
      final result = await provider.editFlower(
        id: 'uuid-mawar',
        namaUmum: 'Mawar Merah',
        namaLatin: 'Rosa rubiginosa',
        makna: 'Cinta Abadi',
        asalBudaya: 'Eropa',
        deskripsi: 'Mawar merah yang elegan.',
      );

      expect(result, isTrue);
    });

    test('editFlower gagal mengembalikan false dan mengisi errorMessage',
            () async {
          provider = FlowerProvider(
            repository: MockFlowerRepository(
              mockFlowers: testFlowers,
              shouldFail: true,
            ),
          );

          final result = await provider.editFlower(
            id: 'uuid-mawar',
            namaUmum: 'Mawar Merah',
            namaLatin: 'Rosa rubiginosa',
            makna: 'Cinta Abadi',
            asalBudaya: 'Eropa',
            deskripsi: 'Mawar merah.',
          );

          expect(result, isFalse);
          expect(provider.errorMessage, isNotEmpty);
        });

    // ── removeFlower ───────────────────────────────────────────────────────

    test('removeFlower berhasil menghapus bunga dari list', () async {
      await provider.loadFlowers();
      final success = await provider.removeFlower('uuid-mawar');

      expect(success, isTrue);
      expect(provider.flowers.any((f) => f.id == 'uuid-mawar'), isFalse);
    });

    test('removeFlower berhasil mengubah status ke success', () async {
      await provider.loadFlowers();
      await provider.removeFlower('uuid-mawar');

      expect(provider.status, equals(FlowerStatus.success));
    });

    test('removeFlower gagal mengembalikan false dan mengisi errorMessage',
            () async {
          provider = FlowerProvider(
            repository: MockFlowerRepository(
              mockFlowers: testFlowers,
              shouldFail: true,
            ),
          );

          await provider.loadFlowers();
          final success = await provider.removeFlower('uuid-mawar');

          expect(success, isFalse);
          expect(provider.errorMessage, isNotEmpty);
        });

    // ── clearSelectedFlower ────────────────────────────────────────────────

    test('clearSelectedFlower mengosongkan selectedFlower', () async {
      await provider.loadFlowerById('uuid-mawar');
      expect(provider.selectedFlower, isNotNull);

      provider.clearSelectedFlower();

      expect(provider.selectedFlower, isNull);
    });

    // ── Listener / notifyListeners ─────────────────────────────────────────

    test('provider memanggil listener saat loadFlowers selesai', () async {
      int callCount = 0;
      provider.addListener(() => callCount++);

      await provider.loadFlowers();

      // loading → success = minimal 2 kali notifyListeners
      expect(callCount, greaterThanOrEqualTo(2));
    });

    test('provider memanggil listener saat updateSearchQuery dipanggil',
            () async {
          int callCount = 0;
          provider.addListener(() => callCount++);

          provider.updateSearchQuery('mawar');

          expect(callCount, equals(1));
        });
  });
}