import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';
import '../models/alert_config.dart';

class AlertService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AlertConfig _config = AlertConfig();
  bool _isPlaying = false;
  bool _isVibrating = false;

  AlertConfig get config => _config;

  void updateConfig(AlertConfig config) {
    _config = config;
  }

  Future<void> playAlertSound(String soundPath) async {
    if (!_config.somAtivo || _isPlaying) return;

    _isPlaying = true;
    try {
      await _audioPlayer.setVolume(_config.intensidadeAlerta);
      await _audioPlayer.play(AssetSource(soundPath));
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      _isPlaying = false;
    }
  }

  Future<void> vibrate() async {
    if (!_config.vibracaoAtiva || _isVibrating) return;

    _isVibrating = true;
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        for (int i = 0; i < 3; i++) {
          Vibration.vibrate(duration: 300);
          await Future.delayed(const Duration(milliseconds: 400));
        }
      }
    } finally {
      _isVibrating = false;
    }
  }

  Future<void> triggerRadarAlert() async {
    if (!_config.alertaRadarProximo) return;

    await Future.wait([
      playAlertSound('sounds/alerta_radar.mp3'),
      vibrate(),
    ]);
  }

  Future<void> triggerSpeedAlert() async {
    if (!_config.alertaExcessoVelocidade) return;

    await Future.wait([
      playAlertSound('sounds/alerta_limite.mp3'),
      vibrate(),
    ]);
  }

  void stopAllAlerts() {
    _audioPlayer.stop();
    _isPlaying = false;
    _isVibrating = false;
  }

  void dispose() {
    stopAllAlerts();
    _audioPlayer.dispose();
  }
}
