import 'package:flutter/material.dart';
import 'package:project_sarpras11/models/barang_model.dart';
import 'package:project_sarpras11/service/barang_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BarangModel> _barangs = [];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final String baseImageUrl = 'http://127.0.0.1:8000/storage/';

  @override
  void initState() {
    super.initState();
    _fetchBarang();
  }

  Future<void> _fetchBarang() async {
    try {
      final service = BarangService();
      final data = await service.fetchBarangs();
      setState(() {
        _barangs = data;
      });
    } catch (e) {
      print('Error ambil barang: $e');
    }
  }

  List<BarangModel> get _filteredBarangs {
    if (_searchQuery.isEmpty) return _barangs;
    return _barangs
        .where((barang) =>
            barang.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar tanpa judul, cukup back button atau warna
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: 0, // sembunyikan AppBar bawaan
      ),
      body: _barangs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar di paling atas
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari barang...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // Judul "Barang Tersedia"
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Barang Tersedia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // List/Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _filteredBarangs.length,
                    itemBuilder: (context, index) {
                      final barang = _filteredBarangs[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '$baseImageUrl${barang.gambar}',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image,
                                            size: 50),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                barang.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kategori: ${barang.kategori.nama}',
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                'Stok: ${barang.stok}',
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
