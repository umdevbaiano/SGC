import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SgcApp());
}

class SgcApp extends StatelessWidget {
  const SgcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGC Pro',
      debugShowCheckedModeBanner: false, // Remove a faixa "Debug" do canto
      theme: AppTheme.lightTheme, // Aplica nosso tema personalizado (Azul/Amarelo)
      home: const LoginScreen(), // Define a tela inicial como o Login
    );
  }
}