
class PeminjamanRiwayat {
  final String tglPeminjaman;
  final String tglPengembalian;
  final String status;
  final List<BarangRiwayat> barangs;

  PeminjamanRiwayat({
    required this.tglPeminjaman,
    required this.tglPengembalian,
    required this.status,
    required this.barangs,
  });

  factory PeminjamanRiwayat.fromJson(Map<String, dynamic> json) {
    var barangsFromJson = json['barangs'] as List;
    List<BarangRiwayat> barangList =
        barangsFromJson.map((b) => BarangRiwayat.fromJson(b)).toList();

    return PeminjamanRiwayat(
      tglPeminjaman: json['tgl_peminjaman'],
      tglPengembalian: json['tgl_pengembalian'],
      status: json['status'],
      barangs: barangList,
    );
  }
}

class BarangRiwayat {
  final int barangId;
  final String namaBarang;
  final int jumlah;

  BarangRiwayat({
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
  });

  factory BarangRiwayat.fromJson(Map<String, dynamic> json) {
    return BarangRiwayat(
      barangId: json['barang_id'],
      namaBarang: json['nama_barang'],
      jumlah: json['jumlah'],
    );
  }
}
