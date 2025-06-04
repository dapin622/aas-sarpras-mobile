import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/peminjaman_model.dart';

class PeminjamanService {
  final String baseUrl = "http://127.0.0.1:8000/api/peminjaman";

  Future<bool> submitPeminjaman(Peminjaman peminjaman) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(peminjaman.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Gagal submit: ${response.body}");
      return false;
    }
  }

  Future<List<Peminjaman>> fetchPeminjamanByUserId(int userId) async {
  final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Peminjaman.fromJson(json)).toList();
  } else {
    throw Exception('Gagal mengambil data peminjaman');
  }
}

}
