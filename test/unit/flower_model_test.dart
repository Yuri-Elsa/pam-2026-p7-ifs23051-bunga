// test/unit/flower_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p7_2026_ifs23051/data/models/flower_model.dart';

void main() {
  group('FlowerModel', () {
    const uuid = '660e8400-e29b-41d4-a716-446655440001';

    const flower = FlowerModel(
      id: uuid,
      namaUmum: 'Mawar',
      namaLatin: 'Rosa',
      makna: 'Cinta dan kasih sayang',
      asalBudaya: 'Eropa Barat',
      deskripsi: 'Bunga dengan kelopak indah dan aroma harum.',
      gambar:
      'https://pam-2026-p4-ifs18005-be.delcom.org:8080/static/flowers/uuid.png',
      pathGambar: 'uploads/flowers/uuid.png',
    );

    test('membuat objek dengan semua field yang benar', () {
      expect(flower.id, equals(uuid));
      expect(flower.namaUmum, equals('Mawar'));
      expect(flower.namaLatin, equals('Rosa'));
      expect(flower.makna, equals('Cinta dan kasih sayang'));
      expect(flower.asalBudaya, equals('Eropa Barat'));
      expect(flower.gambar, contains('/static/flowers/'));
    });

    test('fromJson memetakan semua field dengan benar', () {
      final json = {
        'id': uuid,
        'namaUmum': 'Mawar',
        'namaLatin': 'Rosa',
        'makna': 'Cinta dan kasih sayang',
        'asalBudaya': 'Eropa Barat',
        'deskripsi': 'Bunga dengan kelopak indah dan aroma harum.',
        'gambar':
        'https://pam-2026-p4-ifs18005-be.delcom.org:8080/static/flowers/uuid.png',
        'pathGambar': 'uploads/flowers/uuid.png',
      };
      final result = FlowerModel.fromJson(json);

      expect(result.id, equals(uuid));
      expect(result.namaUmum, equals('Mawar'));
      expect(result.namaLatin, equals('Rosa'));
      expect(result.makna, equals('Cinta dan kasih sayang'));
      expect(result.asalBudaya, equals('Eropa Barat'));
      expect(result.deskripsi, equals('Bunga dengan kelopak indah dan aroma harum.'));
      expect(result.gambar, contains('http'));
      expect(result.pathGambar, contains('uploads/flowers'));
    });

    test('fromJson menggunakan nilai default saat field null', () {
      final json = <String, dynamic>{'id': uuid};
      final result = FlowerModel.fromJson(json);

      expect(result.namaUmum, equals(''));
      expect(result.namaLatin, equals(''));
      expect(result.makna, equals(''));
      expect(result.asalBudaya, equals(''));
      expect(result.deskripsi, equals(''));
      expect(result.gambar, equals(''));
      expect(result.pathGambar, equals(''));
    });

    test('copyWith mengubah hanya field yang diberikan', () {
      final updated = flower.copyWith(namaUmum: 'Melati');

      expect(updated.namaUmum, equals('Melati'));
      expect(updated.id, equals(flower.id));
      expect(updated.namaLatin, equals(flower.namaLatin));
      expect(updated.makna, equals(flower.makna));
      expect(updated.asalBudaya, equals(flower.asalBudaya));
      expect(updated.deskripsi, equals(flower.deskripsi));
    });

    test('copyWith tanpa argumen menghasilkan objek yang identik', () {
      final copy = flower.copyWith();

      expect(copy.id, equals(flower.id));
      expect(copy.namaUmum, equals(flower.namaUmum));
      expect(copy.namaLatin, equals(flower.namaLatin));
      expect(copy.makna, equals(flower.makna));
    });

    test('dua objek dengan UUID yang sama dianggap equal', () {
      const other = FlowerModel(
        id: uuid,
        namaUmum: 'Mawar Berbeda',
        namaLatin: 'Rosa sp.',
        makna: 'Makna lain',
        asalBudaya: 'Asia',
        deskripsi: '-',
      );

      expect(flower, equals(other));
      expect(flower.hashCode, equals(other.hashCode));
    });

    test('dua objek dengan UUID berbeda tidak equal', () {
      const other = FlowerModel(
        id: 'uuid-lain-999',
        namaUmum: 'Mawar',
        namaLatin: 'Rosa',
        makna: 'Cinta dan kasih sayang',
        asalBudaya: 'Eropa Barat',
        deskripsi: 'Bunga dengan kelopak indah.',
      );

      expect(flower, isNot(equals(other)));
    });

    test('toString menampilkan id dan namaUmum', () {
      expect(flower.toString(), contains('Mawar'));
      expect(flower.toString(), contains(uuid));
    });
  });
}