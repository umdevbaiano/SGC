import 'package:flutter/material.dart';

class AppTheme {
  // --- PALETA DE CORES DESBRAVADORES ---
  static const Color primaryBlue = Color(0xFF003366); // Azul Marinho Profundo
  static const Color secondaryGold = Color(0xFFFFC107); // Amarelo Ouro
  static const Color alertRed = Color(0xFFD32F2F); // Vermelho Sóbrio
  static const Color background = Color(0xFFF5F6F9); // Cinza "Gelo" (Moderno)
  static const Color white = Colors.white;

  // --- O TEMA GLOBAL DO APP ---
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: background,
      
      // Configuração da Barra Superior (AppBar)
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: secondaryGold, // Destaque Amarelo no título
        ),
        iconTheme: IconThemeData(color: white),
      ),

      // Configuração dos Botões Principais (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white, // Cor do texto/ícone
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordas arredondadas modernas
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Configuração dos Cards (Cartões de informação)
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // Configuração de Inputs (Campos de Texto)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIconColor: primaryBlue, // Ícones dentro do input ficam azuis
      ),
      
      // Esquema de cores padrão do Material Design
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryBlue,
        secondary: secondaryGold,
      ),
    );
  }
}