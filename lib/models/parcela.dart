class Parcela {
  final String id;
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

  /// 💰 Retorna o valor impactado no mês atual se o contrato estiver ativo e não finalizado
  double get valorDoMes => (ativa && !finalizada) ? valorParcela : 0;
  
  /// 🏁 Verifica se o contrato orbital atingiu o limite de parcelas estabelecido
  bool get finalizada => parcelaAtual > totalParcelas;

  /// ⏩ Adiantar uma parcela (Acelera o cronograma de amortização)
  Parcela adiantar() {
    final proxima = parcelaAtual + 1;
    return copyWith(
      parcelaAtual: proxima,
      ativa: proxima <= totalParcelas,
    );
  }

  /// ⏪ Atrasar uma parcela (Retrocede um ciclo do cronograma se possível)
  Parcela atrasar() {
    if (parcelaAtual <= 1) return this;
    final anterior = parcelaAtual - 1;
    return copyWith(
      parcelaAtual: anterior,
      ativa: true, // Reativa caso estivesse marcada como concluída
    );
  }

  /// 🔄 Mantido por compatibilidade com chamadas antigas de sincronismo de serviços
  Parcela avancarParcela() => adiantar();

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

  factory Parcela.fromMap(Map<String, dynamic> map) {
    return Parcela(
      id: (map['id'] ?? '') as String,
      descricao: (map['descricao'] ?? '') as String,
      valorTotal: _parseDouble(map['valorTotal']),
      valorParcela: _parseDouble(map['valorParcela']),
      totalParcelas: _parseInt(map['totalParcelas'], padrao: 1),
      parcelaAtual: _parseInt(map['parcelaAtual'], padrao: 1),
      ativa: map['ativa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Parcela.fromJson(Map<String, dynamic> json) => Parcela.fromMap(json);

  /// 🧠 Parser seguro para decimais
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  /// 🧠 Parser seguro para inteiros (Evita quebras do JSON no SQLite/Preferences)
  static int _parseInt(dynamic value, {int padrao = 0}) {
    if (value == null) return padrao;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? padrao;
  }
}