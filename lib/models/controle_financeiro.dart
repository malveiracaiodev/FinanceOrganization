class ControleFinanceiro {
  final double receitasExtras;
  final double despesas;
  final double despesasPrevistas;

  const ControleFinanceiro({
    required this.receitasExtras,
    required this.despesas,
    required this.despesasPrevistas,
  });

  double saldoFinal(double salarioBase) {
    return salarioBase +
        receitasExtras -
        despesas -
        despesasPrevistas;
  }

  Map<String, dynamic> toMap() {
    return {
      'receitasExtras': receitasExtras,
      'despesas': despesas,
      'despesasPrevistas': despesasPrevistas,
    };
  }

  factory ControleFinanceiro.fromMap(
    Map<String, dynamic> map,
  ) {
    return ControleFinanceiro(
      receitasExtras:
          (map['receitasExtras'] ?? 0).toDouble(),
      despesas:
          (map['despesas'] ?? 0).toDouble(),
      despesasPrevistas:
          (map['despesasPrevistas'] ?? 0).toDouble(),
    );
  }

  ControleFinanceiro copyWith({
    double? receitasExtras,
    double? despesas,
    double? despesasPrevistas,
  }) {
    return ControleFinanceiro(
      receitasExtras:
          receitasExtras ?? this.receitasExtras,
      despesas:
          despesas ?? this.despesas,
      despesasPrevistas:
          despesasPrevistas ?? this.despesasPrevistas,
    );
  }
}