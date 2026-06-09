class Usuario {
  final String nome;
  final String sobrenome;
  final String empresa;
  final String cargo;
  final double ganhoFixo;

  const Usuario({
    required this.nome,
    required this.sobrenome,
    required this.empresa,
    required this.cargo,
    required this.ganhoFixo,
  });

  /// 👤 nome completo (UI helper)
  String get nomeCompleto => '$nome $sobrenome';

  /// 🔁 copia com alterações (IMPORTANTE para evolução)
  Usuario copyWith({
    String? nome,
    String? sobrenome,
    String? empresa,
    String? cargo,
    double? ganhoFixo,
  }) {
    return Usuario(
      nome: nome ?? this.nome,
      sobrenome: sobrenome ?? this.sobrenome,
      empresa: empresa ?? this.empresa,
      cargo: cargo ?? this.cargo,
      ganhoFixo: ganhoFixo ?? this.ganhoFixo,
    );
  }

  /// 💾 serialização segura
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'sobrenome': sobrenome,
      'empresa': empresa,
      'cargo': cargo,
      'ganhoFixo': ganhoFixo,
    };
  }

  /// 🔐 desserialização robusta
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nome: (map['nome'] ?? '') as String,
      sobrenome: (map['sobrenome'] ?? '') as String,
      empresa: (map['empresa'] ?? '') as String,
      cargo: (map['cargo'] ?? '') as String,
      ganhoFixo: _parseDouble(map['ganhoFixo']),
    );
  }

  /// 🧠 parser seguro (evita crash silencioso)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;
    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }
}