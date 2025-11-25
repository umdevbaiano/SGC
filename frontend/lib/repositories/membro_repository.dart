import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';
import '../models/membro.dart';

class MembroRepository {
  
  // Busca a lista completa de membros
  Future<List<Membro>> getMembros() async {
    // 1. Recuperar o Token salvo no login
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // 2. Fazer a requisição para o Django
    final response = await http.get(
      Uri.parse(ApiConstants.membros),
      headers: {
        'Authorization': 'Token $token', // Apresenta o crachá
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // 3. Converter a lista de JSON para lista de Membros
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Membro.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar membros');
    }
  }
}