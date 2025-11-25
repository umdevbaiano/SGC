import 'package:flutter/material.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  
  // Controladores para animação de entrada
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Configura a animação de entrada (800 milissegundos)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Inicia a animação assim que a tela abre
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Lógica para saudação dinâmica
  String get _greeting {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SGC Pro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded), // Ícone arredondado é mais moderno
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sem novas notificações")),
              );
            },
          ),
          const SizedBox(width: 8), // Espaço extra na direita
        ],
      ),
      
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20), // Um pouco mais de respiro
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Saudação Dinâmica
                Text(
                  "$_greeting, Diretor Samuel!",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Visão Geral",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Carrossel de Resumo (Agora Interativo)
                SizedBox(
                  height: 160, // Aumentamos um pouco para caber o design novo
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(), // Efeito elástico (estilo iOS)
                    children: [
                      _buildSummaryCard(
                        icon: Icons.groups_rounded, 
                        label: "Membros", 
                        value: "42", 
                        color: AppTheme.primaryBlue,
                        onTap: () => print("Clicou em Membros"),
                      ),
                      _buildSummaryCard(
                        icon: Icons.account_balance_wallet_rounded, 
                        label: "Em Caixa", 
                        value: "R\$ 1.250", 
                        color: const Color(0xFF2E7D32), // Verde Floresta
                        onTap: () => print("Clicou em Caixa"),
                      ),
                      _buildSummaryCard(
                        icon: Icons.workspace_premium_rounded, 
                        label: "Classes", 
                        value: "15", 
                        color: AppTheme.secondaryGold,
                        isDarkText: true, // Texto escuro no fundo amarelo fica melhor
                        onTap: () => print("Clicou em Classes"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Seção de Alertas (Visual mais limpo)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Atenção Necessária",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {}, 
                      child: const Text("Ver tudo"),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                
                _buildAlertCard(
                  title: "3 Autorizações Pendentes",
                  subtitle: "Acampamento de Verão",
                  icon: Icons.warning_amber_rounded,
                  color: AppTheme.alertRed,
                  onTap: () {},
                ),
                _buildAlertCard(
                  title: "2 Aniversariantes",
                  subtitle: "Próximos 7 dias",
                  icon: Icons.cake_rounded,
                  color: AppTheme.secondaryGold,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black26,
        indicatorColor: AppTheme.secondaryGold.withOpacity(0.3), // Indicador mais suave
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined), 
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Início'
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded), 
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Membros'
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_money_rounded), 
            label: 'Financ.'
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded), 
            label: 'Menu'
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.secondaryGold,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: AppTheme.primaryBlue, size: 30),
      ),
    );
  }

  // --- WIDGETS REFINADOS ---

  Widget _buildSummaryCard({
    required IconData icon, 
    required String label, 
    required String value, 
    required Color color,
    bool isDarkText = false,
    required VoidCallback onTap,
  }) {
    final textColor = isDarkText ? AppTheme.primaryBlue : Colors.white;
    
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8), // Margem para a sombra
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ícone com fundo translúcido
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: textColor),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value, 
                      style: TextStyle(
                        fontSize: 26, 
                        fontWeight: FontWeight.bold, 
                        color: textColor
                      )
                    ),
                    Text(
                      label, 
                      style: TextStyle(
                        fontSize: 14, 
                        color: textColor.withOpacity(0.8)
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0, // Flat design para a lista, mas com borda
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), // Fundo bem suave da cor do alerta
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey), // Seta indicando clique
            ],
          ),
        ),
      ),
    );
  }
}