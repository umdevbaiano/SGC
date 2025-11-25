import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';
import '../models/membro.dart';

class MembroRepository {
  
  // --- 1. LISTAR TODOS OS MEMBROS (GET) ---
  Future<List<Membro>> getMembros() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiConstants.membros),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Decodifica o JSON (utf8 para acentos funcionarem)
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Converte a lista de JSONs em lista de objetos Membro
        return data.map((json) => Membro.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar membros: ${response.statusCode}');
      }
    } catch (e) {
      // Repassa o erro para quem chamou tratar (ex: mostrar msg na tela)
      throw Exception('Erro de conexão: $e');
    }
  }

  // --- 2. CADASTRAR NOVO MEMBRO (POST) ---
  Future<bool> cadastrarMembro(Map<String, dynamic> dadosMembro) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.membros),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json', // Essencial para enviar dados
        },
        body: jsonEncode(dadosMembro), // Converte o Map do Dart para JSON texto
      );

      if (response.statusCode == 201) {
        // 201 Created = Sucesso absoluto
        return true;
      } else {
        // Log de erro para ajudar a debugar se falhar
        print("Erro API: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erro de conexão ao salvar: $e");
      return false;
    }
  }
}