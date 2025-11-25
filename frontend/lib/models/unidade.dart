class Unidade {
  final int id;
  final String nome;
  final String sexo;

  Unidade({required this.id, required this.nome, required this.sexo});

  factory Unidade.fromJson(Map<String, dynamic> json) {
    return Unidade(
      id: json['id'],
      nome: json['nome'],
      sexo: json['sexo'],
    );
  }
}