class Peminjaman {
   final int id;
  final int userId;
  final String tglPeminjaman;
  final String tglPengembalian;
  final String status;
  String? statusPengembalian; 
  final List<Barang> barangs;

  Peminjaman({
      required this.id,
    required this.userId,
    required this.tglPeminjaman,
    required this.tglPengembalian,
    required this.status,
    this.statusPengembalian,
    required this.barangs,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    var barangList = json['barangs'] as List;
    return Peminjaman(
        id: json['id'],
      userId: json['user_id'],
      tglPeminjaman: json['tgl_peminjaman'],
      tglPengembalian: json['tgl_pengembalian'],
      status: json['status'], 
      statusPengembalian: json['status_pengembalian'], 
      barangs: barangList.map((barang) => Barang.fromJson(barang)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'tgl_peminjaman': tglPeminjaman,
      'tgl_pengembalian': tglPengembalian,
      'status': status, 
      'barangs': barangs.map((b) => b.toJson()).toList(),
    };
  }
}

class Barang {
  final int barangId;
  String namaBarang;
  final int jumlah;

  Barang({
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      barangId: json['barang_id'],
    namaBarang: json['nama_barang'] ?? 'Tidak diketahui', 
      jumlah: json['jumlah'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barang_id': barangId,
      'nama_barang': namaBarang, 
      'jumlah': jumlah,
    };
  }
}
