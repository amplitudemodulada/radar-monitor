import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/gps_service.dart';
import '../utils/constants.dart';

enum GpsStatus { disconnected, searching, connected }

class SpeedProvider extends ChangeNotifier {
  final GpsService _gpsService = GpsService();
  double _speed = 0.0;
  double _maxSpeed = 0.0;
  double _heading = 0.0;
  GpsStatus _gpsStatus = GpsStatus.disconnected;
  Position? _currentPosition;
  double _distance = 0.0;
  bool _isTracking = false;
  int _satellites = 0;
  StreamSubscription<Position>? _positionSub;

  double get speed => _speed;
  double get maxSpeed => _maxSpeed;
  double get heading => _heading;
  GpsStatus get gpsStatus => _gpsStatus;
  Position? get currentPosition => _currentPosition;
  double get distance => _distance;
  bool get isTracking => _isTracking;
  int get satellites => _satellites;

  Future<bool> initialize() async {
    final permission = await _gpsService.requestPermission();
    if (!permission) {
      _gpsStatus = GpsStatus.disconnected;
      notifyListeners();
      return false;
    }

    final gpsEnabled = await _gpsService.isGpsEnabled();
    if (!gpsEnabled) {
      _gpsStatus = GpsStatus.disconnected;
      notifyListeners();
      return false;
    }

    _gpsStatus = GpsStatus.searching;
    notifyListeners();
    return true;
  }

  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;

    _gpsService.startTracking(
      onSpeedUpdate: (speed, heading) {
        _speed = speed;
        _heading = heading;
        if (speed > _maxSpeed) {
          _maxSpeed = speed;
        }
        if (_gpsStatus == GpsStatus.searching) {
          _gpsStatus = GpsStatus.connected;
        }
        notifyListeners();
      },
      onPositionUpdate: (position) {
        _currentPosition = position;
        _gpsStatus = GpsStatus.connected;
        notifyListeners();
      },
      onError: (error) {
        _gpsStatus = GpsStatus.disconnected;
        notifyListeners();
      },
    );
  }

  void stopTracking() {
    _gpsService.stopTracking();
    _isTracking = false;
    _gpsStatus = GpsStatus.disconnected;
    notifyListeners();
  }

  void resetMaxSpeed() {
    _maxSpeed = 0.0;
    notifyListeners();
  }

  void resetDistance() {
    _gpsService.resetTotalDistance();
    _distance = 0.0;
    notifyListeners();
  }

  String get speedFormatted => _speed.toStringAsFixed(0);

  double get speedFraction => (_speed / AppConstants.maxSpeedKmh).clamp(0.0, 1.0);

  @override
  void dispose() {
    _gpsService.dispose();
    super.dispose();
  }
}
