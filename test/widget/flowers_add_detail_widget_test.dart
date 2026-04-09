// test/widget/flowers_add_detail_widget_test.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pam_p7_2026_ifs23051/core/theme/app_theme.dart';
import 'package:pam_p7_2026_ifs23051/core/theme/theme_notifier.dart';
import 'package:pam_p7_2026_ifs23051/data/models/api_response_model.dart';
import 'package:pam_p7_2026_ifs23051/data/models/flower_model.dart';
import 'package:pam_p7_2026_ifs23051/data/services/flower_repository.dart';
import 'package:pam_p7_2026_ifs23051/features/flowers/flowers_add_screen.dart';
import 'package:pam_p7_2026_ifs23051/features/flowers/flowers_detail_screen.dart';
import 'package:pam_p7_2026_ifs23051/providers/flower_provider.dart';

// ── Mock Repository ───────────────────────────────────────────────────────────

class MockFlowerRepository extends FlowerRepository {
  final FlowerModel? flower;
  final bool shouldFail;

  MockFlowerRepository({this.flower, this.shouldFail = false});

  @override
  Future<ApiResponse<FlowerModel>> getFlowerById(String id) async {
    if (shouldFail || flower == null) {
      return const ApiResponse(
          success: false, message: 'Gagal memuat data bunga.');
    }
    return ApiResponse(success: true, message: 'OK', data: flower);
  }

  @override
  Future<ApiResponse<List<FlowerModel>>> getFlowers({String search = ''}) async {
    return ApiResponse(
      success: true,
      message: 'OK',
      data: flower != null ? [flower!] : [],
    );
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
          success: false, message: 'Gagal menambahkan bunga.');
    }
    return const ApiResponse(
        success: true, message: 'Berhasil.', data: 'new-uuid');
  }

  @override
  Future<ApiResponse<void>> deleteFlower(String id) async {
    if (shouldFail) {
      return const ApiResponse(
          success: false, message: 'Gagal menghapus bunga.');
    }
    return const ApiResponse(success: true, message: 'Berhasil.');
  }
}

// ── Builder Helpers ───────────────────────────────────────────────────────────

Widget buildAddScreenTest({bool shouldFail = false}) {
  final notifier = ThemeNotifier(initial: ThemeMode.light);
  final provider = FlowerProvider(
    repository: MockFlowerRepository(shouldFail: shouldFail),
  );
  final router = GoRouter(
    initialLocation: '/flowers/add',
    routes: [
      GoRoute(
        path: '/flowers/add',
        builder: (_, __) => const FlowersAddScreen(),
      ),
      GoRoute(
        path: '/flowers',
        builder: (_, __) => const SizedBox(),
      ),
    ],
  );

  return ThemeProvider(
    notifier: notifier,
    child: ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
}

Widget buildDetailScreenTest({
  required FlowerModel flower,
  bool shouldFail = false,
}) {
  final notifier = ThemeNotifier(initial: ThemeMode.light);
  final provider = FlowerProvider(
    repository: MockFlowerRepository(flower: flower, shouldFail: shouldFail),
  );
  final router = GoRouter(
    initialLocation: '/flowers/${flower.id}',
    routes: [
      GoRoute(
        path: '/flowers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return FlowersDetailScreen(flowerId: id);
        },
      ),
      GoRoute(
        path: '/flowers',
        builder: (_, __) => const SizedBox(),
      ),
      GoRoute(
        path: '/flowers/:id/edit',
        builder: (_, __) => const SizedBox(),
      ),
    ],
  );

  return ThemeProvider(
    notifier: notifier,
    child: ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
}

// ── Test Data ─────────────────────────────────────────────────────────────────

const _testFlower = FlowerModel(
  id: 'uuid-mawar',
  namaUmum: 'Mawar',
  namaLatin: 'Rosa',
  makna: 'Cinta dan kasih sayang',
  asalBudaya: 'Eropa Barat',
  deskripsi: 'Bunga dengan kelopak indah dan aroma harum yang memikat.',
  gambar: 'https://host/static/flowers/mawar.png',
);

// ════════════════════════════════════════════════════════════════════════════
// FlowersAddScreen Tests
// ════════════════════════════════════════════════════════════════════════════

void main() {
  group('FlowersAddScreen', () {
    testWidgets('merender tanpa error', (tester) async {
      await tester.pumpWidget(buildAddScreenTest());
      await tester.pumpAndSettle();

      expect(find.byType(FlowersAddScreen), findsOneWidget);
    });

    testWidgets('menampilkan judul "Tambah Bahasa Bunga" di AppBar',
            (tester) async {
          await tester.pumpWidget(buildAddScreenTest());
          await tester.pumpAndSettle();

          expect(find.text('Tambah Bahasa Bunga'), findsOneWidget);
        });

    testWidgets('menampilkan tombol back di AppBar', (tester) async {
      await tester.pumpWidget(buildAddScreenTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('menampilkan semua field form yang diperlukan', (tester) async {
      await tester.pumpWidget(buildAddScreenTest());
      await tester.pumpAndSettle();

      expect(find.text('Nama Umum'), findsOneWidget);
      expect(find.text('Nama Latin'), findsOneWidget);
      expect(find.text('Makna'), findsOneWidget);
      expect(find.text('Asal Budaya'), findsOneWidget);
      expect(find.text('Deskripsi'), findsOneWidget);
    });

    testWidgets('menampilkan area pilih gambar dengan teks petunjuk',
            (tester) async {
          await tester.pumpWidget(buildAddScreenTest());
          await tester.pumpAndSettle();

          expect(
            find.textContaining('gambar bunga'),
            findsOneWidget,
          );
        });

    testWidgets('menampilkan ikon pilih gambar sebelum gambar dipilih',
            (tester) async {
          await tester.pumpWidget(buildAddScreenTest());
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
        });

    testWidgets('menampilkan tombol Simpan', (tester) async {
      await tester.pumpWidget(buildAddScreenTest());
      await tester.pumpAndSettle();

      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('menampilkan validasi error saat form dikirim kosong',
            (tester) async {
          await tester.pumpWidget(buildAddScreenTest());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Simpan'));
          await tester.pumpAndSettle();

          expect(find.text('Nama Umum tidak boleh kosong.'), findsOneWidget);
        });

    testWidgets('menampilkan ikon-ikon field form yang benar', (tester) async {
      await tester.pumpWidget(buildAddScreenTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_florist_outlined), findsOneWidget);
      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.byIcon(Icons.public_outlined), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('menampilkan Form widget', (tester) async {
      await tester.pumpWidget(buildAddScreenTest());
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('form dapat menerima input teks pada field Nama Umum',
            (tester) async {
          await tester.pumpWidget(buildAddScreenTest());
          await tester.pumpAndSettle();

          final field = find.widgetWithText(TextFormField, 'Nama Umum');
          await tester.enterText(field, 'Anggrek');
          await tester.pump();

          expect(find.text('Anggrek'), findsOneWidget);
        });

    testWidgets('menampilkan snackbar saat gambar belum dipilih & form valid',
            (tester) async {
          await tester.pumpWidget(buildAddScreenTest());
          await tester.pumpAndSettle();

          // Isi semua field teks
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Nama Umum'), 'Anggrek');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Nama Latin'), 'Orchidaceae');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Makna'), 'Keindahan');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Asal Budaya'), 'Asia Tropis');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Deskripsi'), 'Bunga eksotis.');
          await tester.pump();

          await tester.tap(find.text('Simpan'));
          await tester.pumpAndSettle();

          expect(
            find.text('Pilih gambar terlebih dahulu.'),
            findsOneWidget,
          );
        });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // FlowersDetailScreen Tests
  // ════════════════════════════════════════════════════════════════════════════

  group('FlowersDetailScreen', () {
    testWidgets('merender tanpa error', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      expect(find.byType(FlowersDetailScreen), findsOneWidget);
    });

    testWidgets('menampilkan nama umum bunga sebagai judul AppBar',
            (tester) async {
          await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
          await tester.pumpAndSettle();

          expect(find.text('Mawar'), findsWidgets);
        });

    testWidgets('menampilkan nama latin bunga (italic)', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      expect(find.text('Rosa'), findsOneWidget);
    });

    testWidgets('menampilkan makna bunga dalam badge', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      expect(find.text('Cinta dan kasih sayang'), findsOneWidget);
    });

    testWidgets('menampilkan card Deskripsi', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      expect(find.text('Deskripsi'), findsOneWidget);
      expect(
        find.text('Bunga dengan kelopak indah dan aroma harum yang memikat.'),
        findsOneWidget,
      );
    });

    testWidgets('menampilkan card Asal Budaya', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      expect(find.text('Asal Budaya'), findsOneWidget);
      expect(find.text('Eropa Barat'), findsOneWidget);
    });

    testWidgets('menampilkan menu edit dan hapus (more_vert)', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('membuka menu dropdown saat more_vert ditekan', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('menampilkan dialog konfirmasi saat Hapus dipilih',
            (tester) async {
          await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.more_vert));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Hapus'));
          await tester.pumpAndSettle();

          expect(find.text('Hapus Bunga'), findsOneWidget);
          expect(find.text('Batal'), findsOneWidget);
        });

    testWidgets('dialog konfirmasi memiliki tombol Batal dan Hapus',
            (tester) async {
          await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.more_vert));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Hapus'));
          await tester.pumpAndSettle();

          expect(find.text('Batal'), findsOneWidget);
          expect(
            find.widgetWithText(FilledButton, 'Hapus'),
            findsOneWidget,
          );
        });

    testWidgets('menutup dialog saat Batal ditekan', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Dialog hilang, detail screen masih ada
      expect(find.text('Hapus Bunga'), findsNothing);
      expect(find.byType(FlowersDetailScreen), findsOneWidget);
    });

    testWidgets('menampilkan error widget saat API gagal', (tester) async {
      await tester.pumpWidget(
        buildDetailScreenTest(flower: _testFlower, shouldFail: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
    });

    testWidgets('menampilkan tombol back di AppBar', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('halaman dapat di-scroll', (tester) async {
      await tester.pumpWidget(buildDetailScreenTest(flower: _testFlower));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
