class Membro {
  final int id;
  final String nomeCompleto;
  final String cargo;
  final String cargoDisplay; // O nome bonitinho ("Diretor" em vez de "DIR")
  final String? unidadeNome; // Pode ser nulo se não tiver unidade
  final bool ativo;

  Membro({
    required this.id,
    required this.nomeCompleto,
    required this.cargo,
    required this.cargoDisplay,
    this.unidadeNome,
    required this.ativo,
  });

  // A Fábrica: Pega o JSON do Django e cria um Membro Flutter
  factory Membro.fromJson(Map<String, dynamic> json) {
    return Membro(
      id: json['id'],
      nomeCompleto: json['nome_completo'],
      cargo: json['cargo'],
      cargoDisplay: json['cargo_display'] ?? json['cargo'],
      unidadeNome: json['unidade_detalhes'] != null 
          ? json['unidade_detalhes']['nome'] 
          : null,
      ativo: json['ativo'] ?? true,
    );
  }
}