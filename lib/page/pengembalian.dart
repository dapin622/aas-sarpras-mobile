import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_sarpras11/models/peminjaman_model.dart';
import 'package:project_sarpras11/models/pengembalian_model.dart';
import 'package:project_sarpras11/service/pengembalian_service.dart';

class PengembalianPage extends StatefulWidget {
  const PengembalianPage({super.key});

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  late Peminjaman peminjaman;
  final PengembalianService _pengembalianService = PengembalianService();

  bool _isLoading = false;
  DateTime? _selectedTanggalPengembalian;
  double _denda = 0;
  bool _initialized = false;

  static const double dendaPerJam = 1000;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      peminjaman = ModalRoute.of(context)!.settings.arguments as Peminjaman;
      _selectedTanggalPengembalian = DateTime.now(); 
      _calculateDenda();
      _initialized = true;
    }
  }

  void _calculateDenda() {
    if (_selectedTanggalPengembalian == null) {
      _denda = 0;
      return;
    }

    final batasPengembalian = DateTime.parse(peminjaman.tglPengembalian);
    final terlambat = _selectedTanggalPengembalian!.difference(batasPengembalian);

    if (terlambat.inSeconds <= 0) {
      _denda = 0;
    } else {
      _denda = terlambat.inHours * dendaPerJam;
    }
  }

  Future<void> _konfirmasiPengembalian() async {
    if (_selectedTanggalPengembalian == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih tanggal dan waktu pengembalian')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool semuaBerhasil = true;

    for (var barang in peminjaman.barangs) {
      final pengembalian = Pengembalian(
        peminjamanId: peminjaman.id,
        barangId: barang.barangId,
        jumlah: barang.jumlah,
        tglPengembalian: _selectedTanggalPengembalian!.toIso8601String(),
      );

      final success = await _pengembalianService.kirimPengembalian(pengembalian);
      if (!success) {
        semuaBerhasil = false;
        break;
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (semuaBerhasil) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Menunggu konfirmasi admin...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      final pengembalians = await _pengembalianService.getPengembalianByPeminjamanId(peminjaman.id);

      double totalDenda = 0;
      if (pengembalians != null) {
        for (var p in pengembalians) {
          totalDenda += p.denda ?? 0;
        }
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Informasi Denda'),
          content: Text(totalDenda > 0
              ? 'Admin telah memberikan denda sebesar Rp ${totalDenda.toStringAsFixed(0)}'
              : 'Tidak ada denda dari admin.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Barang berhasil dikembalikan')),
      );
      Navigator.pop(context, 'success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gagal melakukan pengembalian')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final batasPengembalianFormatted =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(peminjaman.tglPengembalian));

    final tanggalPengembalianFormatted = _selectedTanggalPengembalian != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(_selectedTanggalPengembalian!)
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Batas Pengembalian: $batasPengembalianFormatted',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tanggal & Waktu Pengembalian',
                border: OutlineInputBorder(),
                // suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(text: tanggalPengembalianFormatted),
            ),

            const SizedBox(height: 12),

            const Text(
              'Daftar Barang:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...peminjaman.barangs.map(
              (barang) => Text(
                '${barang.namaBarang} - Jumlah: ${barang.jumlah}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _konfirmasiPengembalian,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Konfirmasi Pengembalian'),
                  ),
          ],
        ),
      ),
    );
  }
}
