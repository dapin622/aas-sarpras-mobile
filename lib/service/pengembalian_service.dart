import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pengembalian_model.dart';

class PengembalianService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // ← baseUrl sudah mengandung /api

  Future<bool> kirimPengembalian(Pengembalian pengembalian) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pengembalian'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pengembalian.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Gagal: ${response.statusCode} - ${response.body}");
      return false;
    }
  }

  // Future<List<Pengembalian>> fetchPengembalianUser(int userId) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/pengembalian/user/$userId'),
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonList = json.decode(response.body);
  //     return jsonList.map((json) => Pengembalian.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load pengembalian user: ${response.body}');
  //   }
  // }

  Future<List<Pengembalian>?> getPengembalianByPeminjamanId(int peminjamanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengembalian/peminjaman/$peminjamanId'), 
        headers: {'Accept': 'application/json'},
      );

      print("Status Code: ${response.statusCode}");
      print("Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Decoded JSON: $data");
        return data.map((e) => Pengembalian.fromJson(e)).toList();
      } else {
        print("Gagal mendapatkan data pengembalian. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error saat getPengembalianByPeminjamanId: $e");
      return null;
    }
  }
}
