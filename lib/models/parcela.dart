class Parcela {
  final String id; // ID necessário para sabermos qual parcela deletar/editar
  final String descricao;
  final double valorTotal;
  final double valorParcela;
  final int totalParcelas;
  final int parcelaAtual;
  final bool ativa;

  const Parcela({
    required this.id,
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
      id: id,
      descricao: descricao,
      valorTotal: valorTotal,
      valorParcela: valorParcela,
      totalParcelas: totalParcelas,
      parcelaAtual: proxima,
      ativa: proxima <= totalParcelas,
    );
  }

  /// 🔁 copia com alterações (Padrão do seu projeto)
  Parcela copyWith({
    String? id,
    String? descricao,
    double? valorTotal,
    double? valorParcela,
    int? totalParcelas,
    int? parcelaAtual,
    bool? ativa,
  }) {
    return Parcela(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valorTotal: valorTotal ?? this.valorTotal,
      valorParcela: valorParcela ?? this.valorParcela,
      totalParcelas: totalParcelas ?? this.totalParcelas,
      parcelaAtual: parcelaAtual ?? this.parcelaAtual,
      ativa: ativa ?? this.ativa,
    );
  }

  /// 💾 serialização segura
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      id: (map['id'] ?? '') as String,
      descricao: (map['descricao'] ?? '') as String,
      valorTotal: _parseDouble(map['valorTotal']),
      valorParcela: _parseDouble(map['valorParcela']),
      totalParcelas: (map['totalParcelas'] ?? 1) as int,
      parcelaAtual: (map['parcelaAtual'] ?? 1) as int,
      ativa: map['ativa'] ?? true,
    );
  }

  // 🔄 Aliases para sincronizar com os métodos nativos do SharedPreferences/JSON
  Map<String, dynamic> toJson() => toMap();
  factory Parcela.fromJson(Map<String, dynamic> json) => Parcela.fromMap(json);

  /// 🧠 parser seguro
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}