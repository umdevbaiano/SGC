import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Lógica inteligente para definir o endereço correto
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api"; // Web (Localhost)
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/api"; // Emulador Android (IP Especial)
    } else {
      return "http://127.0.0.1:8000/api"; // iOS / Desktop
    }
  }

  // Endpoints (As rotas)
  static String get login => "$baseUrl/login/";
  static String get membros => "$baseUrl/membros/";
  static String get unidades => "$baseUrl/unidades/";
}