class Pengembalian {
  final int? id;
  final int? peminjamanId;
  final int? barangId;
  final int jumlah;
  final String tglPengembalian;
  final double? denda; // ← Tambahkan ini

  Pengembalian({
    this.id,
    required this.peminjamanId,
    required this.barangId,
    required this.jumlah,
    required this.tglPengembalian,
    this.denda, 
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'],
      peminjamanId: json['peminjaman_id'],
      barangId: json['barang_id'],
      jumlah: json['jumlah'],
      tglPengembalian: json['tgl_pengembalian'],
      denda: json['denda'] != null ? double.tryParse(json['denda'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peminjaman_id': peminjamanId,
      'barang_id': barangId,
      'jumlah': jumlah,
      'tgl_pengembalian': tglPengembalian,
      'denda': denda, 
    };
  }
}
