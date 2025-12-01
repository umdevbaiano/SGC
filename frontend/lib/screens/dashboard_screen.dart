import 'package:flutter/material.dart';
import '../theme.dart';
import '../repositories/membro_repository.dart';
import 'membros_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// REMOVIDO: "with SingleTickerProviderStateMixin" (Não precisamos mais do relógio)
class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _totalMembros = "..."; 

  @override
  void initState() {
    super.initState();
    // REMOVIDO: Toda a configuração de AnimationController
    _carregarDados();
  }

  // REMOVIDO: dispose() (Não há nada para limpar)

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
      if (mounted) setState(() => _totalMembros = "-");
    }
  }

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
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // REMOVIDO: FadeTransition / SlideTransition
      // CORPO LIMPO E DIRETO
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: SingleChildScrollView(
          // IMPORTANTE: ClampingScrollPhysics faz o scroll parecer "nativo" do Windows (sem elástico)
          physics: const ClampingScrollPhysics(), 
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  // IMPORTANTE: Scroll Sólido Horizontal também
                  physics: const ClampingScrollPhysics(), 
                  children: [
                    _buildSummaryCard(
                      icon: Icons.groups_rounded, 
                      label: "Membros", 
                      value: _totalMembros,
                      color: AppTheme.primaryBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MembrosListScreen()),
                        ).then((_) => _carregarDados());
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
                  TextButton(onPressed: () {}, child: const Text("Ver tudo"))
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

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) { 
            Navigator.push(
              context,
              // Voltamos para a rota padrão do sistema para testar performance
              MaterialPageRoute(builder: (context) => const MembrosListScreen()),
            ).then((_) {
              setState(() => _selectedIndex = 0);
              _carregarDados();
            });
          }
        },
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black26,
        indicatorColor: AppTheme.secondaryGold.withOpacity(0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'Membros'),
          NavigationDestination(icon: Icon(Icons.attach_money_rounded), label: 'Financ.'),
          NavigationDestination(icon: Icon(Icons.menu_rounded), label: 'Menu'),
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

  // --- WIDGETS CUSTOMIZADOS ---
  // (Mantenha os widgets _buildSummaryCard e _buildAlertCard exatamente iguais ao anterior)
  Widget _buildSummaryCard({required IconData icon, required String label, required String value, required Color color, bool isDarkText = false, required VoidCallback onTap}) {
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
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(icon, size: 24, color: textColor),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
                    Text(label, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
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
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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