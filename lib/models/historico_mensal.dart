class HistoricoMensal {
  final String mesAno;
  final double ganhoFixo;
  final double ganhosAdicionais;
  final double gastosTotais;

  const HistoricoMensal({
    required this.mesAno,
    required this.ganhoFixo,
    required this.ganhosAdicionais,
    required this.gastosTotais,
  });

  /// 📊 resultado do mês
  double get resto =>
      ganhoFixo + ganhosAdicionais - gastosTotais;

  /// 💾 serialização
  Map<String, dynamic> toMap() {
    return {
      'mesAno': mesAno,
      'ganhoFixo': ganhoFixo,
      'ganhosAdicionais': ganhosAdicionais,
      'gastosTotais': gastosTotais,
    };
  }

  /// 🔐 desserialização segura
  factory HistoricoMensal.fromMap(Map<String, dynamic> map) {
    return HistoricoMensal(
      mesAno: (map['mesAno'] ?? '') as String,
      ganhoFixo: _parseDouble(map['ganhoFixo']),
      ganhosAdicionais: _parseDouble(map['ganhosAdicionais']),
      gastosTotais: _parseDouble(map['gastosTotais']),
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