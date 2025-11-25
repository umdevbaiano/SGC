import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/membro.dart';

class MembroDetalhesScreen extends StatefulWidget {
  final Membro membro;

  // Recebemos o objeto Membro inteiro vindo da lista
  const MembroDetalhesScreen({super.key, required this.membro});

  @override
  State<MembroDetalhesScreen> createState() => _MembroDetalhesScreenState();
}

class _MembroDetalhesScreenState extends State<MembroDetalhesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Configura o controlador para 3 abas
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // Helper para pegar as iniciais
    final nomes = widget.membro.nomeCompleto.split(' ');
    String iniciais = nomes[0][0];
    if (nomes.length > 1) iniciais += nomes.last[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil do Membro"),
        elevation: 0, // Remove sombra para fundir com o cabeçalho
      ),
      body: Column(
        children: [
          // --- CABEÇALHO COM HERO ANIMATION ---
          Container(
            width: double.infinity,
            color: AppTheme.primaryBlue, // Fundo azul contínuo
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                // A Mágica da Animação: Hero
                Hero(
                  tag: 'avatar-${widget.membro.id}', // Tag única
                  child: CircleAvatar(
                    radius: 50, // Avatar grande
                    backgroundColor: AppTheme.secondaryGold,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: AppTheme.white,
                      child: Text(
                        iniciais.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.membro.nomeCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.membro.cargoDisplay.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.secondaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- BARRA DE ABAS ---
          Container(
            color: AppTheme.primaryBlue, // Continua o fundo azul
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.secondaryGold,
              indicatorWeight: 4,
              labelColor: AppTheme.secondaryGold,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: "GERAL"),
                Tab(text: "SAÚDE"),
                Tab(text: "HISTÓRICO"),
              ],
            ),
          ),

          // --- CONTEÚDO DAS ABAS ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba 1: Geral
                _buildAbaGeral(),
                // Aba 2: Saúde (Futuro)
                const Center(child: Text("Ficha Médica em breve...")),
                // Aba 3: Histórico (Futuro)
                const Center(child: Text("Histórico de Classes em breve...")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbaGeral() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard("Informações Básicas", [
          _buildInfoRow(Icons.badge, "Cargo", widget.membro.cargoDisplay),
          _buildInfoRow(Icons.shield, "Unidade", widget.membro.unidadeNome ?? "Sem Unidade"),
          _buildInfoRow(Icons.verified_user, "Status", widget.membro.ativo ? "Ativo" : "Inativo"),
        ]),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}