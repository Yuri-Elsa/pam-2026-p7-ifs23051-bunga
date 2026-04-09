// lib/data/models/flower_model.dart

/// Model data untuk bahasa bunga
/// Menggunakan immutable class (best practice Flutter/Dart)
class FlowerModel {
  const FlowerModel({
    this.id,
    required this.namaUmum,
    required this.namaLatin,
    required this.makna,
    required this.asalBudaya,
    required this.deskripsi,
    this.gambar = '',
    this.pathGambar = '',
  });

  /// UUID dari database
  final String? id;
  final String namaUmum;
  final String namaLatin;
  final String makna;
  final String asalBudaya;
  final String deskripsi;

  /// URL publik gambar dari server
  final String gambar;

  /// Path relatif file di server
  final String pathGambar;

  /// Membuat FlowerModel dari JSON (response API)
  factory FlowerModel.fromJson(Map<String, dynamic> json) {
    return FlowerModel(
      id: json['id'] as String?,
      namaUmum: json['namaUmum'] as String? ?? '',
      namaLatin: json['namaLatin'] as String? ?? '',
      makna: json['makna'] as String? ?? '',
      asalBudaya: json['asalBudaya'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      gambar: json['gambar'] as String? ?? '',
      pathGambar: json['pathGambar'] as String? ?? '',
    );
  }

  FlowerModel copyWith({
    String? id,
    String? namaUmum,
    String? namaLatin,
    String? makna,
    String? asalBudaya,
    String? deskripsi,
    String? gambar,
    String? pathGambar,
  }) {
    return FlowerModel(
      id: id ?? this.id,
      namaUmum: namaUmum ?? this.namaUmum,
      namaLatin: namaLatin ?? this.namaLatin,
      makna: makna ?? this.makna,
      asalBudaya: asalBudaya ?? this.asalBudaya,
      deskripsi: deskripsi ?? this.deskripsi,
      gambar: gambar ?? this.gambar,
      pathGambar: pathGambar ?? this.pathGambar,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FlowerModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FlowerModel(id: $id, namaUmum: $namaUmum)';
}