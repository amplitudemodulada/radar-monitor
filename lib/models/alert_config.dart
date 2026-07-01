class AlertConfig {
  bool somAtivo;
  bool vibracaoAtiva;
  double intensidadeAlerta;
  double distanciaAlerta;
  bool alertaExcessoVelocidade;
  bool alertaRadarProximo;
  double velocidadeExcedida;

  AlertConfig({
    this.somAtivo = true,
    this.vibracaoAtiva = true,
    this.intensidadeAlerta = 1.0,
    this.distanciaAlerta = 500.0,
    this.alertaExcessoVelocidade = true,
    this.alertaRadarProximo = true,
    this.velocidadeExcedida = 1.1,
  });

  Map<String, dynamic> toJson() {
    return {
      'somAtivo': somAtivo,
      'vibracaoAtiva': vibracaoAtiva,
      'intensidadeAlerta': intensidadeAlerta,
      'distanciaAlerta': distanciaAlerta,
      'alertaExcessoVelocidade': alertaExcessoVelocidade,
      'alertaRadarProximo': alertaRadarProximo,
      'velocidadeExcedida': velocidadeExcedida,
    };
  }

  factory AlertConfig.fromJson(Map<String, dynamic> json) {
    return AlertConfig(
      somAtivo: json['somAtivo'] as bool? ?? true,
      vibracaoAtiva: json['vibracaoAtiva'] as bool? ?? true,
      intensidadeAlerta: (json['intensidadeAlerta'] as num?)?.toDouble() ?? 1.0,
      distanciaAlerta: (json['distanciaAlerta'] as num?)?.toDouble() ?? 500.0,
      alertaExcessoVelocidade:
          json['alertaExcessoVelocidade'] as bool? ?? true,
      alertaRadarProximo: json['alertaRadarProximo'] as bool? ?? true,
      velocidadeExcedida:
          (json['velocidadeExcedida'] as num?)?.toDouble() ?? 1.1,
    );
  }
}
