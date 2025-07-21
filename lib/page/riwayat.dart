import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_sarpras11/models/barang_model.dart';
import 'package:project_sarpras11/models/kategori_model.dart';
import 'package:project_sarpras11/models/peminjaman_model.dart';
import 'package:project_sarpras11/models/pengembalian_model.dart';
import 'package:project_sarpras11/service/barang_service.dart';
import 'package:project_sarpras11/service/peminjaman_service.dart';
import 'package:project_sarpras11/service/pengembalian_service.dart';

class RiwayatPeminjaman extends StatefulWidget {
  const RiwayatPeminjaman({Key? key}) : super(key: key);

  @override
  State<RiwayatPeminjaman> createState() => _RiwayatPeminjamanState();
}

class _RiwayatPeminjamanState extends State<RiwayatPeminjaman> {
  final PeminjamanService _peminjamanService = PeminjamanService();
  final PengembalianService _pengembalianService = PengembalianService();
  int? _userId;
  late Future<List<Peminjaman>> _futurePeminjaman;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');

    if (_userId != null) {
      try {
        final peminjamanData = await _peminjamanService.fetchPeminjamanByUserId(_userId!);
        final barangList = await BarangService().fetchBarangs();

        for (var p in peminjamanData) {
          for (var b in p.barangs) {
            final barangMatch = barangList.firstWhere(
              (barang) => barang.id == b.barangId,
              orElse: () => BarangModel(
                id: 0,
                nama: 'Tidak diketahui',
                gambar: '',
                stok: 0,
                kategori: KategoriModel(id: 0, nama: 'Unknown'),
              ),
            );
            b.namaBarang = barangMatch.nama;
          }
        }

        if (mounted) {
          setState(() {
            _futurePeminjaman = Future.value(peminjamanData);
          });
        }
      } catch (e) {
        debugPrint('❌ Gagal ambil data: $e');
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('Memuat...')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Peminjaman')),
      body: FutureBuilder<List<Peminjaman>>(
        future: _futurePeminjaman,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final peminjamanList = snapshot.data!;
          if (peminjamanList.isEmpty) {
            return const Center(child: Text('Belum ada riwayat peminjaman.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: peminjamanList.length,
            itemBuilder: (context, index) {
              final peminjaman = peminjamanList[index];

              return FutureBuilder<List<Pengembalian>?>(
                future: peminjaman.statusPengembalian == 'sudah_dikembalikan'
                    ? _pengembalianService.getPengembalianByPeminjamanId(peminjaman.id!)
                    : Future.value(null),
                builder: (context, snapshotPengembalian) {
                  double totalDenda = 0;
                  if (snapshotPengembalian.hasData) {
                    totalDenda = snapshotPengembalian.data!.fold(
                      0,
                      (sum, item) => sum + (item.denda ?? 0),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peminjaman: ${peminjaman.tglPeminjaman} - ${peminjaman.tglPengembalian}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...peminjaman.barangs.map(
                            (b) => Text('Barang: ${b.namaBarang}, Jumlah: ${b.jumlah}'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${peminjaman.status}',
                            style: TextStyle(
                              color: getStatusColor(peminjaman.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (peminjaman.status.toLowerCase() == 'approved') ...[
                            if (peminjaman.statusPengembalian == 'sudah_dikembalikan') ...[
                              ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                child: const Text('Sudah Dikembalikan'),
                              ),
                              const SizedBox(height: 6),
                              if (snapshotPengembalian.connectionState == ConnectionState.waiting)
                                const Text('Memuat denda...'),
                              if (snapshotPengembalian.hasData)
                                Text(
                                  totalDenda > 0
                                      ? 'Denda dari admin: Rp ${totalDenda.toStringAsFixed(0)}'
                                      : 'Tidak ada denda dari admin',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: totalDenda > 0 ? Colors.red : Colors.green,
                                  ),
                                ),
                            ] else
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/pengembalian',
                                    arguments: peminjaman,
                                  );

                                  if (result == 'success' && mounted) {
                                    _loadData(); 
                                  }
                                },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Kembalikan'),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}  