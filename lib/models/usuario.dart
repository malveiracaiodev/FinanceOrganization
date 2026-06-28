class Usuario {
  final String nome;
  final String sobrenome;
  final String empresa;
  final String cargo;
  final double ganhoFixo;
  final double saldoAtual;
  final int ultimoMesVerificado;

  const Usuario({
    required this.nome,
    required this.sobrenome,
    required this.empresa,
    required this.cargo,
    required this.ganhoFixo,
    required this.saldoAtual,
    required this.ultimoMesVerificado,
  });

  /// 👤 Nome completo do Comandante da Missão
  String get nomeCompleto => '$nome $sobrenome';

  /// 🔁 Cópia com alterações (Crucial para atualização de saldo pós-missão)
  Usuario copyWith({
    String? nome,
    String? sobrenome,
    String? empresa,
    String? cargo,
    double? ganhoFixo,
    double? saldoAtual,
    int? ultimoMesVerificado,
  }) {
    return Usuario(
      nome: nome ?? this.nome,
      sobrenome: sobrenome ?? this.sobrenome,
      empresa: empresa ?? this.empresa,
      cargo: cargo ?? this.cargo,
      ganhoFixo: ganhoFixo ?? this.ganhoFixo,
      saldoAtual: saldoAtual ?? this.saldoAtual,
      ultimoMesVerificado: ultimoMesVerificado ?? this.ultimoMesVerificado,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'sobrenome': sobrenome,
      'empresa': empresa,
      'cargo': cargo,
      'ganhoFixo': ganhoFixo,
      'saldoAtual': saldoAtual,
      'ultimoMesVerificado': ultimoMesVerificado,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nome: (map['nome'] ?? '') as String,
      sobrenome: (map['sobrenome'] ?? '') as String,
      empresa: (map['empresa'] ?? '') as String,
      cargo: (map['cargo'] ?? '') as String,
      ganhoFixo: _parseDouble(map['ganhoFixo']),
      saldoAtual: _parseDouble(map['saldoAtual'] ?? map['ganhoFixo']), 
      ultimoMesVerificado: _parseInt(map['ultimoMesVerificado'], padrao: DateTime.now().month),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario.fromMap(json);

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value, {int padrao = 0}) {
    if (value == null) return padrao;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? padrao;
  }
}