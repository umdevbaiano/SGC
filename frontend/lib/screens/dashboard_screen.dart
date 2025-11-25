import 'package:flutter/material.dart';
import '../theme.dart';
import '../repositories/membro_repository.dart';
import 'membros_list_screen.dart'; // Import da tela de lista

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  
  // Variável de Estado para os dados reais
  String _totalMembros = "..."; 

  // Controladores de Animação de Entrada
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // 1. Configura a Animação de Entrada
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

    _controller.forward();

    // 2. Busca os Dados Reais da API
    _carregarDados();
  }

  // Função que vai até o Django buscar os dados
  Future<void> _carregarDados() async {
    try {
      final repo = MembroRepository();
      final membros = await repo.getMembros();
      
      if (mounted) {
        setState(() {
          _totalMembros = membros.length.toString();
        });
      }
    } catch (e) {
      print("Erro ao carregar dados: $e");
      if (mounted) {
        setState(() {
          _totalMembros = "-"; // Indica erro visualmente
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _greeting {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  // --- FUNÇÃO DE NAVEGAÇÃO COM ANIMAÇÃO LATERAL ---
  Route _criarRotaComSlide(Widget pagina) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => pagina,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Começa na direita
        const end = Offset.zero;        // Termina no centro
        const curve = Curves.ease;      // Curva suave

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SGC Pro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: _carregarDados,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saudação
                  Text(
                    "$_greeting, Diretor!",
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

                  // Carrossel de Resumo
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildSummaryCard(
                          icon: Icons.groups_rounded, 
                          label: "Membros", 
                          value: _totalMembros,
                          color: AppTheme.primaryBlue,
                          onTap: () {
                            // Navega usando a animação de slide
                            Navigator.push(
                              context,
                              _criarRotaComSlide(const MembrosListScreen()),
                            );
                          },
                        ),
                        _buildSummaryCard(
                          icon: Icons.account_balance_wallet_rounded, 
                          label: "Em Caixa", 
                          value: "R\$ 1.250", 
                          color: const Color(0xFF2E7D32), 
                          onTap: () {},
                        ),
                        _buildSummaryCard(
                          icon: Icons.workspace_premium_rounded, 
                          label: "Classes", 
                          value: "15", 
                          color: AppTheme.secondaryGold,
                          isDarkText: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Alertas
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
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);

          // Lógica de Navegação da Barra Inferior
          if (index == 1) { // Membros
            Navigator.push(
              context,
              _criarRotaComSlide(const MembrosListScreen()),
            ).then((_) {
              // Quando voltar, reseta o ícone para Home
              setState(() => _selectedIndex = 0);
            });
          }
        },
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black26,
        indicatorColor: AppTheme.secondaryGold.withOpacity(0.3),
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
        onPressed: () {
          // Futuro: Tela de cadastro rápido
        },
        backgroundColor: AppTheme.secondaryGold,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: AppTheme.primaryBlue, size: 30),
      ),
    );
  }

  // --- WIDGETS CUSTOMIZADOS ---

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
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
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
      elevation: 0,
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
                  color: color.withOpacity(0.1),
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
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}