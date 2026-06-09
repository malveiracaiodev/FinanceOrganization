class Parcela {
  final String descricao;
  final double valorTotal;
  final double valorParcela;
  final int totalParcelas;
  final int parcelaAtual;
  final bool ativa;

  const Parcela({
    required this.descricao,
    required this.valorTotal,
    required this.valorParcela,
    required this.totalParcelas,
    this.parcelaAtual = 1,
    this.ativa = true,
  });

  /// 💰 valor que impacta o mês atual
  double get valorDoMes => ativa ? valorParcela : 0;

  /// ✔ já terminou todas as parcelas
  bool get finalizada => parcelaAtual >= totalParcelas;

  /// 🔄 próxima parcela (imutável)
  Parcela avancarParcela() {
    final proxima = parcelaAtual + 1;

    return Parcela(
      descricao: descricao,
      valorTotal: valorTotal,
      valorParcela: valorParcela,
      totalParcelas: totalParcelas,
      parcelaAtual: proxima,
      ativa: proxima <= totalParcelas,
    );
  }

  /// 💾 serialização segura
  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'valorTotal': valorTotal,
      'valorParcela': valorParcela,
      'totalParcelas': totalParcelas,
      'parcelaAtual': parcelaAtual,
      'ativa': ativa,
    };
  }

  /// 🔐 desserialização robusta
  factory Parcela.fromMap(Map<String, dynamic> map) {
    return Parcela(
      descricao: (map['descricao'] ?? '') as String,
      valorTotal: _parseDouble(map['valorTotal']),
      valorParcela: _parseDouble(map['valorParcela']),
      totalParcelas: (map['totalParcelas'] ?? 1) as int,
      parcelaAtual: (map['parcelaAtual'] ?? 1) as int,
      ativa: map['ativa'] ?? true,
    );
  }

  /// 🧠 parser seguro
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}