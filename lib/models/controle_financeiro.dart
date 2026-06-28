class ControleFinanceiro {
  final double receitasExtras;
  final double despesas;
  final double despesasPrevistas;

  const ControleFinanceiro({
    this.receitasExtras = 0.0,
    this.despesas = 0.0,
    this.despesasPrevistas = 0.0,
  });

  /// 🧮 Calcula o saldo final real deduzindo entradas e saídas (Inclui as faturas de parcelas)
  double saldoFinal(double ganhoFixo, {double totalParcelasDoMes = 0.0}) {
    return (ganhoFixo + receitasExtras) - (despesas + totalParcelasDoMes);
  }

  /// 🔁 Imutabilidade: Cria uma cópia com novos dados alterados
  ControleFinanceiro copyWith({
    double? receitasExtras,
    double? despesas,
    double? despesasPrevistas,
  }) {
    return ControleFinanceiro(
      receitasExtras: receitasExtras ?? this.receitasExtras,
      despesas: despesas ?? this.despesas,
      despesasPrevistas: despesasPrevistas ?? this.despesasPrevistas,
    );
  }

  /// 💾 Converte para salvar localmente (Chaves em String explícitas para o ProGuard)
  Map<String, dynamic> toMap() {
    return {
      'receitasExtras': receitasExtras,
      'despesas': despesas,
      'despesasPrevistas': despesasPrevistas,
    };
  }

  /// 🔐 Mapeamento reverso com proteção matemática anti-nulo
  factory ControleFinanceiro.fromMap(Map<String, dynamic> map) {
    return ControleFinanceiro(
      receitasExtras: _parseDouble(map['receitasExtras']),
      despesas: _parseDouble(map['despesas']),
      despesasPrevistas: _parseDouble(map['despesasPrevistas']),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory ControleFinanceiro.fromJson(Map<String, dynamic> json) => ControleFinanceiro.fromMap(json);

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}