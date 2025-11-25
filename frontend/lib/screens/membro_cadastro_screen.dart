import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar data (adicione no pubspec se precisar: flutter pub add intl)
import '../theme.dart';
import '../models/unidade.dart';
import '../repositories/unidade_repository.dart';
import '../repositories/membro_repository.dart';

class MembroCadastroScreen extends StatefulWidget {
  const MembroCadastroScreen({super.key});

  @override
  State<MembroCadastroScreen> createState() => _MembroCadastroScreenState();
}

class _MembroCadastroScreenState extends State<MembroCadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _nomeController = TextEditingController();
  final _nascimentoController = TextEditingController();
  
  // Variáveis de Estado
  String? _sexoSelecionado;
  String? _cargoSelecionado;
  int? _unidadeIdSelecionada;
  List<Unidade> _listaUnidades = [];
  bool _isLoading = false;

  // Listas fixas (iguais ao Django)
  final List<String> _sexos = ['M', 'F'];
  final Map<String, String> _cargos = {
    'DBV': 'Desbravador',
    'CONS': 'Conselheiro',
    'DIR': 'Diretor',
    'SEC': 'Secretário',
    'TES': 'Tesoureiro',
    'CAPU': 'Capitão',
  };

  @override
  void initState() {
    super.initState();
    _carregarUnidades();
  }

  Future<void> _carregarUnidades() async {
    try {
      final unidades = await UnidadeRepository().getUnidades();
      setState(() {
        _listaUnidades = unidades;
      });
    } catch (e) {
      print("Erro ao carregar unidades: $e");
    }
  }

  Future<void> _selecionarData() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime(2010), // Começa em uma data "juvenil"
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );

    if (data != null) {
      // Formata para o padrão brasileiro visualmente
      // Mas lembre-se: O Django espera YYYY-MM-DD
      setState(() {
        _nascimentoController.text = DateFormat('yyyy-MM-dd').format(data);
      });
    }
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final dados = {
        "nome_completo": _nomeController.text,
        "sexo": _sexoSelecionado,
        "cargo": _cargoSelecionado,
        "data_nascimento": _nascimentoController.text,
        "unidade_id": _unidadeIdSelecionada,
        "ativo": true
      };

      final sucesso = await MembroRepository().cadastrarMembro(dados);

      setState(() => _isLoading = false);

      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Membro cadastrado com sucesso!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Volta para a lista atualizando
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao salvar. Verifique os dados."), backgroundColor: AppTheme.alertRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Membro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Dados Pessoais", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              const SizedBox(height: 16),
              
              // Nome
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome Completo",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 16),

              // Data de Nascimento
              TextFormField(
                controller: _nascimentoController,
                readOnly: true, // Não deixa digitar, só clicar
                onTap: _selecionarData,
                decoration: const InputDecoration(
                  labelText: "Data de Nascimento",
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 16),

              // Sexo (Dropdown)
              DropdownButtonFormField<String>(
                initialValue: _sexoSelecionado,
                decoration: const InputDecoration(
                  labelText: "Sexo",
                  prefixIcon: Icon(Icons.wc),
                ),
                items: _sexos.map((sexo) => DropdownMenuItem(
                  value: sexo,
                  child: Text(sexo == 'M' ? 'Masculino' : 'Feminino'),
                )).toList(),
                onChanged: (v) => setState(() => _sexoSelecionado = v),
                validator: (v) => v == null ? "Selecione o sexo" : null,
              ),
              const SizedBox(height: 16),

              const Text("Dados do Clube", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              const SizedBox(height: 16),

              // Cargo (Dropdown)
              DropdownButtonFormField<String>(
                initialValue: _cargoSelecionado,
                decoration: const InputDecoration(
                  labelText: "Cargo",
                  prefixIcon: Icon(Icons.badge),
                ),
                items: _cargos.entries.map((entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                )).toList(),
                onChanged: (v) => setState(() => _cargoSelecionado = v),
                validator: (v) => v == null ? "Selecione um cargo" : null,
              ),
              const SizedBox(height: 16),

              // Unidade (Dropdown dinâmico vindo da API)
              DropdownButtonFormField<int>(
                initialValue: _unidadeIdSelecionada,
                decoration: const InputDecoration(
                  labelText: "Unidade",
                  prefixIcon: Icon(Icons.shield),
                ),
                items: _listaUnidades.map((unidade) => DropdownMenuItem(
                  value: unidade.id,
                  child: Text(unidade.nome),
                )).toList(),
                onChanged: (v) => setState(() => _unidadeIdSelecionada = v),
                // Unidade não é obrigatória no backend, mas aqui podemos decidir
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvar,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SALVAR CADASTRO"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}