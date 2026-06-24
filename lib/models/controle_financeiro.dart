class ControleFinanceiro {
  final double receitasExtras;
  final double despesas;
  final double despesasPrevistas;

  const ControleFinanceiro({
    required this.receitasExtras,
    required this.despesas,
    required this.despesasPrevistas,
  });

  /// 💰 Calcula o saldo final do mês injetando o salário base 
  /// e subtraindo também o total das parcelas vigentes na Mark I.
  double saldoFinal(double salarioBase, {double totalParcelasDoMes = 0}) {
    return salarioBase +
        receitasExtras -
        despesas -
        despesasPrevistas -
        totalParcelasDoMes; // 🔥 Agora o parcelamento reduz o saldo real!
  }

  Map<String, dynamic> toMap() {
    return {
      'receitasExtras': receitasExtras,
      'despesas': despesas,
      'despesasPrevistas': despesasPrevistas,
    };
  }

  factory ControleFinanceiro.fromMap(Map<String, dynamic> map) {
    return ControleFinanceiro(
      receitasExtras: _parseDouble(map['receitasExtras']),
      despesas: _parseDouble(map['despesas']),
      despesasPrevistas: _parseDouble(map['despesasPrevistas']),
    );
  }

  // 🔄 Aliases de compatibilidade para o padrão JSON do Service
  Map<String, dynamic> toJson() => toMap();
  factory ControleFinanceiro.fromJson(Map<String, dynamic> json) => ControleFinanceiro.fromMap(json);

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

  /// 🧠 Mantendo o seu padrão de parser seguro para evitar falhas no JSON
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}