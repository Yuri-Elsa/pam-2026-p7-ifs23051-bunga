// test/screens/flowers_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pam_p7_2026_ifs23051/core/theme/app_theme.dart';
import 'package:pam_p7_2026_ifs23051/core/theme/theme_notifier.dart';
import 'package:pam_p7_2026_ifs23051/data/models/api_response_model.dart';
import 'package:pam_p7_2026_ifs23051/data/models/flower_model.dart';
import 'package:pam_p7_2026_ifs23051/data/services/flower_repository.dart';
import 'package:pam_p7_2026_ifs23051/features/flowers/flowers_screen.dart';
import 'package:pam_p7_2026_ifs23051/providers/flower_provider.dart';

class MockFlowerRepository extends FlowerRepository {
  final List<FlowerModel> flowers;
  final bool shouldFail;

  MockFlowerRepository(this.flowers, {this.shouldFail = false});

  @override
  Future<ApiResponse<List<FlowerModel>>> getFlowers({String search = ''}) async {
    if (shouldFail) {
      return const ApiResponse(
        success: false,
        message: 'Gagal memuat data bunga.',
      );
    }
    return ApiResponse(success: true, message: 'OK', data: flowers);
  }
}

Widget buildFlowersScreenTest(
    List<FlowerModel> flowers, {
      bool shouldFail = false,
    }) {
  final notifier = ThemeNotifier(initial: ThemeMode.light);
  final provider = FlowerProvider(
    repository: MockFlowerRepository(flowers, shouldFail: shouldFail),
  );
  final router = GoRouter(
    initialLocation: '/flowers',
    routes: [
      GoRoute(
        path: '/flowers',
        builder: (_, __) => const FlowersScreen(),
      ),
      GoRoute(
        path: '/flowers/add',
        builder: (_, __) => const SizedBox(),
      ),
      GoRoute(
        path: '/flowers/:id',
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
      deskripsi: 'Bunga putih harum.',
      gambar: 'https://host/static/flowers/melati.png',
    ),
  ];

  group('FlowersScreen', () {
    // ── Render & Konten Dasar ──────────────────────────────────────────────

    testWidgets('merender tanpa error', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.byType(FlowersScreen), findsOneWidget);
    });

    testWidgets('menampilkan judul "Bahasa Bunga" di AppBar', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.text('Bahasa Bunga'), findsOneWidget);
    });

    testWidgets('menampilkan daftar bunga dari API', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.text('Mawar'), findsOneWidget);
      expect(find.text('Melati'), findsOneWidget);
    });

    testWidgets('menampilkan nama latin bunga (italic)', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.text('Rosa'), findsOneWidget);
      expect(find.text('Jasminum sambac'), findsOneWidget);
    });

    testWidgets('menampilkan badge makna pada setiap bunga', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.text('Cinta'), findsOneWidget);
      expect(find.text('Kesucian'), findsOneWidget);
    });

    // ── Keadaan Kosong ────────────────────────────────────────────────────

    testWidgets('menampilkan pesan kosong ketika tidak ada bunga',
            (tester) async {
          await tester.pumpWidget(buildFlowersScreenTest([]));
          await tester.pumpAndSettle();

          expect(find.text('Tidak ada data bahasa bunga!'), findsOneWidget);
        });

    // ── FAB ───────────────────────────────────────────────────────────────

    testWidgets('menampilkan FAB untuk tambah bunga', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    // ── Search ────────────────────────────────────────────────────────────

    testWidgets('menampilkan ikon search di AppBar', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('menekan ikon search menampilkan TextField', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('menutup search menghapus TextField', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    // ── Error State ───────────────────────────────────────────────────────

    testWidgets('menampilkan widget error saat API gagal', (tester) async {
      await tester.pumpWidget(
        buildFlowersScreenTest([], shouldFail: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
    });

    testWidgets('menampilkan tombol "Coba Lagi" saat terjadi error',
            (tester) async {
          await tester.pumpWidget(
            buildFlowersScreenTest([], shouldFail: true),
          );
          await tester.pumpAndSettle();

          expect(find.text('Coba Lagi'), findsOneWidget);
        });

    // ── ListView ──────────────────────────────────────────────────────────

    testWidgets('menampilkan ListView saat data tersedia', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('setiap item bunga memiliki ikon chevron_right', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    });

    testWidgets('RefreshIndicator tersedia di halaman bunga', (tester) async {
      await tester.pumpWidget(buildFlowersScreenTest(testFlowers));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}