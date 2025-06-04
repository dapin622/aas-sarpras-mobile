import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_sarpras11/models/barang_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_sarpras11/models/peminjaman_model.dart';
import 'package:project_sarpras11/service/peminjaman_service.dart';
import 'package:project_sarpras11/service/barang_service.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({Key? key}) : super(key: key);

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _tglPeminjamanController = TextEditingController();
  final _tglPengembalianController = TextEditingController();

  final _peminjamanService = PeminjamanService();
  int? _userId;

  List<BarangModel> _listBarang = [];
  BarangModel? _selectedBarang;

  @override
  void initState() {
    super.initState();
    _fetchBarang();
    _loadUserId();
  }

  Future<void> _fetchBarang() async {
    try {
      final barangService = BarangService();
      final data = await barangService.fetchBarangs();
      setState(() {
        _listBarang = data;
      });
    } catch (e) {
      print('Gagal ambil barang: $e');
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    controller.text = DateFormat('yyyy-MM-dd HH:mm').format(combined);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBarang == null || _selectedBarang!.stok == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Tidak bisa meminjam, stok barang habis')),
        );
        return;
      }

      final jumlah = int.tryParse(_jumlahController.text) ?? 0;
      if (jumlah > _selectedBarang!.stok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Jumlah melebihi stok (${_selectedBarang!.stok})')),
        );
        return;
      }

      if (_userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ User ID tidak ditemukan. Silakan login ulang.')),
        );
        return;
      }

      try {
            final peminjaman = Peminjaman(
              id: 0, 
        userId: _userId!,
        tglPeminjaman: _tglPeminjamanController.text,
        tglPengembalian: _tglPengembalianController.text,
        status: 'pending', 
        barangs: [
          Barang(
            barangId: _selectedBarang!.id,
            namaBarang: _selectedBarang!.nama ,
            jumlah: jumlah,
          ),
        ],
      );


        await _peminjamanService.submitPeminjaman(peminjaman);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Peminjaman berhasil dikirim')),
        );
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Gagal mengirim data: $e')),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _jumlahController.clear();
    _tglPeminjamanController.clear();
    _tglPengembalianController.clear();
    _selectedBarang = null;
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _tglPeminjamanController.dispose();
    _tglPengembalianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Peminjaman')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<BarangModel>(
                value: _selectedBarang,
                items: _listBarang.map((barang) {
                  return DropdownMenuItem(
                    value: barang,
                    child: Text('${barang.nama} '),
                  );
                }).toList(),
                onChanged: (barang) {
                  if (barang != null && barang.stok == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ Stok barang habis')),
                    );
                    return;
                  }
                  setState(() {
                    _selectedBarang = barang;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Pilih Barang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Pilih barang terlebih dahulu' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tglPeminjamanController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Peminjaman',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDateTime(context, _tglPeminjamanController),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tglPengembalianController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Pengembalian',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDateTime(context, _tglPengembalianController),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final jumlah = int.tryParse(value ?? '');
                  if (value == null || value.isEmpty) return 'Masukkan jumlah';
                  if (jumlah == null || jumlah <= 0) return 'Jumlah harus valid';
                  if (_selectedBarang != null && jumlah > _selectedBarang!.stok) {
                    return 'Jumlah melebihi stok (${_selectedBarang!.stok})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                   backgroundColor: const Color(0xFF2C3E50), 
                  foregroundColor: Colors.white, 
                ),
                child: const Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
