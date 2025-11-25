import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';

class AuthService {
  // Função para fazer Login
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Sucesso! O Django devolveu o Token
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Salvar o token no celular
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        
        return true; // Login aprovado
      } else {
        return false; // Senha errada ou erro
      }
    } catch (e) {
      print("Erro de conexão: $e");
      return false;
    }
  }

  // Função para sair (Logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Função para verificar se já está logado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}