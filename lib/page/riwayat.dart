import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_sarpras11/service/barang_service.dart';
import 'package:project_sarpras11/models/barang_model.dart';
import 'package:project_sarpras11/models/peminjaman_model.dart';
import 'package:project_sarpras11/service/peminjaman_service.dart';
import 'package:project_sarpras11/models/kategori_model.dart';

class RiwayatPeminjaman extends StatefulWidget {
  const RiwayatPeminjaman({Key? key}) : super(key: key);

  @override
  State<RiwayatPeminjaman> createState() => _RiwayatPeminjamanState();
}

class _RiwayatPeminjamanState extends State<RiwayatPeminjaman> {
  Set<int> _peminjamanSelesai = {};
  final PeminjamanService _peminjamanService = PeminjamanService();
  int? _userId;
  late Future<List<Peminjaman>> _futurePeminjaman;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetch();
  }

  Future<void> _loadUserIdAndFetch() async {
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

        // Set data peminjaman yang sudah dikembalikan (opsional)
        _peminjamanSelesai = peminjamanData
            .where((p) => p.statusPengembalian == 'sudah_dikembalikan')
            .map((p) => p.id!)
            .toSet();

        setState(() {
          _futurePeminjaman = Future.value(peminjamanData);
        });

      } catch (e) {
        print('❌ Gagal load data: $e');
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
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Peminjaman')),
        body: const Center(child: Text('Tunggu Sebentar')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Peminjaman')),
      body: FutureBuilder<List<Peminjaman>>(
        future: _futurePeminjaman,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada riwayat peminjaman'));
          }

          final peminjamanList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: peminjamanList.length,
            itemBuilder: (context, index) {
              final peminjaman = peminjamanList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peminjaman:  ${peminjaman.tglPeminjaman}  -  ${peminjaman.tglPengembalian}',
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
                      if (peminjaman.status.toLowerCase() == 'approved') ...[
                        const SizedBox(height: 10),
                        peminjaman.statusPengembalian == 'sudah_dikembalikan'
                            ? ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(80, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Sudah Dikembalikan'),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/pengembalian',
                                    arguments: peminjaman,
                                  );

                                  if (result == 'success') {
                                    // Refresh data peminjaman terbaru dari backend
                                    final peminjamanDataBaru = await _peminjamanService.fetchPeminjamanByUserId(_userId!);
                                    final barangList = await BarangService().fetchBarangs();

                                    for (var p in peminjamanDataBaru) {
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

                                    setState(() {
                                      _futurePeminjaman = Future.value(peminjamanDataBaru);
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(80, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
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
      ),
    );
  }
}
