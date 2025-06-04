import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_sarpras11/models/barang_model.dart';

class BarangService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<BarangModel>> fetchBarangs() async {
    final response = await http.get(Uri.parse('$baseUrl/barang'));

  //   print('STATUS CODE: ${response.statusCode}');
  // print('BODY: ${response.body}');

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    if (jsonData['data'] is List) {
      final List<dynamic> list = jsonData['data'];
      return list.map((item) => BarangModel.fromJson(item)).toList();
    } else {
      throw Exception('Response "data" bukan list: ${jsonData['data']}');
    }
  } else {
    throw Exception('Failed to load barang');
  }
  }
}
