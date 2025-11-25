import 'package:flutter/material.dart';
import '../theme.dart'; // Importando nossas cores
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para pegar o texto digitado
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Variável para controlar o "olhinho" da senha
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white, // Fundo branco limpo
      body: Center(
        child: SingleChildScrollView( // Permite rolar se a tela for pequena
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estica tudo
            children: [
              // 1. LOGO E TÍTULO
              const Icon(
                Icons.diamond_outlined, // Placeholder para sua logo SGC
                size: 80,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              const Text(
                "SGC Pro",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Entre para gerenciar seu clube",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // 2. CAMPO DE E-MAIL
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Usuário ou E-mail",
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // 3. CAMPO DE SENHA
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure, // Oculta a senha
                decoration: InputDecoration(
                  labelText: "Senha",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure; // Troca o estado do olhinho
                      });
                    },
                  ),
                ),
              ),
              
              // 4. ESQUECI MINHA SENHA
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, // Ação futura
                  child: const Text("Esqueci minha senha"),
                ),
              ),
              const SizedBox(height: 24),

              // 5. BOTÃO ENTRAR
              SizedBox(
                height: 56, // Botão alto e moderno
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  child: const Text("ENTRAR"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}