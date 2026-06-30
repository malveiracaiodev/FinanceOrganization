class ControleFinanceiro {
  final double receitasExtras;
  final double despesas;

  const ControleFinanceiro({
    this.receitasExtras = 0.0,
    this.despesas = 0.0,
  });

  /// 🧮 Calcula o saldo final real deduzindo entradas e saídas (Inclui as faturas de parcelas)
  double saldoFinal(double ganhoFixo, {double totalParcelasDoMes = 0.0}) {
    return (ganhoFixo + receitasExtras) - (despesas + totalParcelasDoMes);
  }

  /// 🔁 Imutabilidade: Cria uma cópia com novos dados alterados
  ControleFinanceiro copyWith({
    double? receitasExtras,
    double? despesas,
  }) {
    return ControleFinanceiro(
      receitasExtras: receitasExtras ?? this.receitasExtras,
      despesas: despesas ?? this.despesas,
    );
  }

  /// 💾 Converte para salvar localmente (Chaves em String explícitas para o ProGuard)
  Map<String, dynamic> toMap() {
    return {
      'receitasExtras': receitasExtras,
      'despesas': despesas,
    };
  }

  /// 🔐 Mapeamento reverso com proteção matemática anti-nulo
  factory ControleFinanceiro.fromMap(Map<String, dynamic> map) {
    return ControleFinanceiro(
      receitasExtras: _parseDouble(map['receitasExtras']),
      despesas: _parseDouble(map['despesas']),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory ControleFinanceiro.fromJson(Map<String, dynamic> map) => ControleFinanceiro.fromMap(map);

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // --- ADICIONADO: MELHORIAS TÉCNICAS DE QUALIDADE DE CÓDIGO ---

  /// 🔍 Sobrescrita do toString() para facilitar a depuração no console
  @override
  String toString() {
    return 'ControleFinanceiro(receitasExtras: $receitasExtras, despesas: $despesas)';
  }

  /// ⚖️ Sobrescrita da igualdade para comparação de valores internos (Ideal para testes e reatividade)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ControleFinanceiro &&
        other.receitasExtras == receitasExtras &&
        other.despesas == despesas;
  }

  /// 🔢 HashCode correspondente à lógica de igualdade de valor
  @override
  int get hashCode => receitasExtras.hashCode ^ despesas.hashCode;
}