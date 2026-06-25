class HistoricoMensal {
  final String mesAno; // 📅 Ex: "06/2026" (Chave única para divisão perfeita)
  final double ganhoFixo;
  final double ganhosAdicionais;
  final double gastosTotais;

  const HistoricoMensal({
    required this.mesAno,
    required this.ganhoFixo,
    required this.ganhosAdicionais,
    required this.gastosTotais,
  });

  /// 📊 Resultado líquido do mês (Saldo que sobrou)
  double get resto =>
      ganhoFixo + ganhosAdicionais - gastosTotais;

  /// 📈 Receita total gerada no ciclo correspondente
  double get receitaTotal => ganhoFixo + ganhosAdicionais;

  /// ⭕ Percentual de orçamento consumido neste registro histórico (0.0 a 1.0)
  double get percentualConsumido {
    final total = receitaTotal;
    if (total <= 0) return 1.0;
    return (gastosTotais / total).clamp(0.0, 1.0);
  }

  /// 🚦 Status Operacional da Missão Passada
  String get statusOrbital {
    final saldo = resto;
    if (saldo >= receitaTotal * 0.2) {
      return "Sistemas Operando: Saúde excelente 🟢";
    } else if (saldo >= 0) {
      return "Sistemas Operando: Órbita estável 🟡";
    } else {
      return "Aviso Crítico: Déficit na Órbita 🔴";
    }
  }

  /// 🔁 NOVO: Permite edição/cópia com alterações dos meses passados
  HistoricoMensal copyWith({
    String? mesAno,
    double? ganhoFixo,
    double? ganhosAdicionais,
    double? gastosTotais,
  }) {
    return HistoricoMensal(
      mesAno: mesAno ?? this.mesAno,
      ganhoFixo: ganhoFixo ?? this.ganhoFixo,
      ganhosAdicionais: ganhosAdicionais ?? this.ganhosAdicionais,
      gastosTotais: gastosTotais ?? this.gastosTotais,
    );
  }

  /// 💾 Serialização
  Map<String, dynamic> toMap() {
    return {
      'mesAno': mesAno,
      'ganhoFixo': ganhoFixo,
      'ganhosAdicionais': ganhosAdicionais,
      'gastosTotais': gastosTotais,
    };
  }

  /// 🔐 Desserialização segura
  factory HistoricoMensal.fromMap(Map<String, dynamic> map) {
    return HistoricoMensal(
      mesAno: (map['mesAno'] ?? '') as String,
      ganhoFixo: _parseDouble(map['ganhoFixo']),
      ganhosAdicionais: _parseDouble(map['ganhosAdicionais']),
      gastosTotais: _parseDouble(map['gastosTotais']),
    );
  }

  // 🔄 Aliases de compatibilidade adicionados para sincronizar com o HistoricoService
  Map<String, dynamic> toJson() => toMap();
  factory HistoricoMensal.fromJson(Map<String, dynamic> json) => HistoricoMensal.fromMap(json);

  /// 🧠 Parser seguro
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}