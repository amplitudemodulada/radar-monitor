import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/alert_config.dart';
import '../models/radar_point.dart';
import '../services/alert_service.dart';
import '../utils/constants.dart';

enum AlertType { radarProximo, excessoVelocidade, none }

class AlertProvider extends ChangeNotifier {
  final AlertService _alertService = AlertService();
  AlertType _currentAlert = AlertType.none;
  RadarPoint? _alertingRadar;
  bool _isAlerting = false;
  DateTime? _lastAlertTime;
  double _configDistance = AppConstants.radarAlertDistance;

  AlertConfig get config => _alertService.config;
  AlertType get currentAlert => _currentAlert;
  RadarPoint? get alertingRadar => _alertingRadar;
  bool get isAlerting => _isAlerting;
  double get configDistance => _configDistance;

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('alertConfig');
    if (json != null) {
      final config = AlertConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
      _alertService.updateConfig(config);
      _configDistance = config.distanciaAlerta;
      notifyListeners();
    }
  }

  Future<void> saveConfig(AlertConfig config) async {
    _alertService.updateConfig(config);
    _configDistance = config.distanciaAlerta;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alertConfig', jsonEncode(config.toJson()));
    notifyListeners();
  }

  Future<void> updateConfigField(String field, dynamic value) async {
    final config = _alertService.config;
    switch (field) {
      case 'somAtivo':
        config.somAtivo = value as bool;
        break;
      case 'vibracaoAtiva':
        config.vibracaoAtiva = value as bool;
        break;
      case 'intensidadeAlerta':
        config.intensidadeAlerta = (value as num).toDouble();
        break;
      case 'distanciaAlerta':
        config.distanciaAlerta = (value as num).toDouble();
        _configDistance = config.distanciaAlerta;
        break;
      case 'alertaExcessoVelocidade':
        config.alertaExcessoVelocidade = value as bool;
        break;
      case 'alertaRadarProximo':
        config.alertaRadarProximo = value as bool;
        break;
      case 'velocidadeExcedida':
        config.velocidadeExcedida = (value as num).toDouble();
        break;
    }
    await saveConfig(config);
  }

  Future<void> checkRadarAlert(
    List<RadarPoint> nearbyRadars,
    double currentSpeed,
    double userLat,
    double userLon,
  ) async {
    if (_isAlerting) return;
    if (!_alertService.config.alertaRadarProximo) return;

    for (final radar in nearbyRadars) {
      final distance = radar.distanceTo(userLat, userLon);

      if (distance <= _configDistance) {
        _currentAlert = AlertType.radarProximo;
        _alertingRadar = radar;
        _isAlerting = true;
        _lastAlertTime = DateTime.now();

        _alertService.triggerRadarAlert();
        notifyListeners();

        Future.delayed(const Duration(seconds: 5), () {
          _isAlerting = false;
          _currentAlert = AlertType.none;
          notifyListeners();
        });
        break;
      }
    }
  }

  Future<void> checkSpeedAlert(
    double currentSpeed,
    double maxSpeed,
  ) async {
    if (_isAlerting) return;
    if (!_alertService.config.alertaExcessoVelocidade) return;

    final threshold = maxSpeed * _alertService.config.velocidadeExcedida;
    if (currentSpeed >= threshold && maxSpeed > 0) {
      _currentAlert = AlertType.excessoVelocidade;
      _isAlerting = true;
      _lastAlertTime = DateTime.now();

      _alertService.triggerSpeedAlert();
      notifyListeners();

      Future.delayed(const Duration(seconds: 4), () {
        _isAlerting = false;
        _currentAlert = AlertType.none;
        notifyListeners();
      });
    }
  }

  void dismissAlert() {
    _alertService.stopAllAlerts();
    _isAlerting = false;
    _currentAlert = AlertType.none;
    notifyListeners();
  }

  @override
  void dispose() {
    _alertService.dispose();
    super.dispose();
  }
}
