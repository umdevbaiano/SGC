import 'package:flutter/gestures.dart';
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // AQUI ESTÁ A MÁGICA DA FLUIDEZ
      scrollBehavior: const SmoothScrollBehavior(),
      
      home: const LoginScreen(),
    );
  }
}

// --- CLASSE DE ROLAGEM SUAVE (SMOOTH SCROLL) ---
class SmoothScrollBehavior extends MaterialScrollBehavior {
  const SmoothScrollBehavior();

  // 1. Permite arrastar com o mouse (como em tablets)
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };

  // 2. Aplica uma física que "desliza" em vez de travar
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
  
  // 3. Configura a densidade para Desktop (menos apertado)
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}