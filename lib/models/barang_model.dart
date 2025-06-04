import 'kategori_model.dart';

class BarangModel {
  final int id;
  final String nama;
  final String gambar;
  final int stok;
  final KategoriModel kategori;

  BarangModel({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.stok,
    required this.kategori,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      id: json['id'],
      nama: json['nama'],
      gambar: json['gambar'],
      stok: json['stok'],
      kategori: KategoriModel.fromJson(json['kategori']),
    );
  }
}
