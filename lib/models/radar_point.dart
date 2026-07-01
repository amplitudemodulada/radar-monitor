class RadarPoint {
  final int id;
  final double latitude;
  final double longitude;
  final String tipo;
  final int velocidadeMaxima;
  final String direcao;
  final bool ativo;

  RadarPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.tipo,
    required this.velocidadeMaxima,
    required this.direcao,
    required this.ativo,
  });

  factory RadarPoint.fromJson(Map<String, dynamic> json) {
    return RadarPoint(
      id: json['id'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      tipo: json['tipo'] as String? ?? 'fixo',
      velocidadeMaxima: json['velocidade_maxima'] as int? ?? 60,
      direcao: json['direcao'] as String? ?? 'ambos',
      ativo: json['ativo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
      'velocidade_maxima': velocidadeMaxima,
      'direcao': direcao,
      'ativo': ativo,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
      'velocidade_maxima': velocidadeMaxima,
      'direcao': direcao,
      'ativo': ativo ? 1 : 0,
    };
  }

  factory RadarPoint.fromMap(Map<String, dynamic> map) {
    return RadarPoint(
      id: map['id'] as int,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      tipo: map['tipo'] as String,
      velocidadeMaxima: map['velocidade_maxima'] as int,
      direcao: map['direcao'] as String,
      ativo: (map['ativo'] as int) == 1,
    );
  }

  double distanceTo(double lat, double lon) {
    const R = 6371000.0;
    final dLat = _toRadians(lat - latitude);
    final dLon = _toRadians(lon - longitude);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(latitude)) *
            _cos(_toRadians(lat)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  double _sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  double _atan2(double y, double x) {
    if (x > 0) return (y / x) - (y * y * y) / (3 * x * x * x);
    if (x < 0 && y >= 0) return 3.141592653589793 + (y / x);
    if (x < 0 && y < 0) return -3.141592653589793 + (y / x);
    return y >= 0 ? 3.141592653589793 / 2 : -3.141592653589793 / 2;
  }
}
