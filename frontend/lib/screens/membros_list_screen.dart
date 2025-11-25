import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/membro.dart';
import '../repositories/membro_repository.dart';

class MembrosListScreen extends StatefulWidget {
  const MembrosListScreen({super.key});

  @override
  State<MembrosListScreen> createState() => _MembrosListScreenState();
}

class _MembrosListScreenState extends State<MembrosListScreen> {
  final MembroRepository _repository = MembroRepository();
  
  List<Membro> _todosMembros = []; // Lista original
  List<Membro> _membrosFiltrados = []; // Lista exibida (busca)
  bool _isLoading = true;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _carregarMembros();
  }

  Future<void> _carregarMembros() async {
    try {
      final dados = await _repository.getMembros();
      setState(() {
        _todosMembros = dados;
        _membrosFiltrados = dados; // No início, mostra tudo
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar membros. Verifique sua conexão.';
        _isLoading = false;
      });
    }
  }

  // Função de Busca em Tempo Real
  void _filtrarLista(String query) {
    final filtro = query.toLowerCase();
    setState(() {
      _membrosFiltrados = _todosMembros.where((m) {
        final nome = m.nomeCompleto.toLowerCase();
        final cargo = m.cargoDisplay.toLowerCase();
        return nome.contains(filtro) || cargo.contains(filtro);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Membros do Clube"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: _filtrarLista,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou cargo...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      
      body: _buildBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Futuro: Tela de Cadastro
        },
        backgroundColor: AppTheme.secondaryGold,
        child: const Icon(Icons.person_add, color: AppTheme.primaryBlue),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.alertRed),
            const SizedBox(height: 16),
            Text(_erro),
            TextButton(onPressed: _carregarMembros, child: const Text("Tentar Novamente"))
          ],
        ),
      );
    }

    if (_membrosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Nenhum membro encontrado", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _membrosFiltrados.length,
      itemBuilder: (context, index) {
        final membro = _membrosFiltrados[index];
        return _buildMembroCard(membro);
      },
    );
  }

  Widget _buildMembroCard(Membro membro) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: _buildAvatar(membro),
        title: Text(
          membro.nomeCompleto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(membro.cargoDisplay, style: TextStyle(color: AppTheme.primaryBlue.withOpacity(0.8))),
            if (membro.unidadeNome != null)
              Text("Unidade: ${membro.unidadeNome}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () {
          // Futuro: Ir para Detalhes
        },
      ),
    );
  }

  // Gera um avatar colorido com as iniciais
  Widget _buildAvatar(Membro membro) {
    // Pega a primeira letra do primeiro e último nome
    final nomes = membro.nomeCompleto.split(' ');
    String iniciais = nomes[0][0];
    if (nomes.length > 1) {
      iniciais += nomes.last[0];
    }

    // Define cor baseada se está ativo ou não
    final corFundo = membro.ativo ? AppTheme.primaryBlue : Colors.grey;

    return CircleAvatar(
      radius: 24,
      backgroundColor: corFundo.withOpacity(0.1),
      child: Text(
        iniciais.toUpperCase(),
        style: TextStyle(
          color: corFundo,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}