import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class GpsService {
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;
  double _currentSpeed = 0.0;
  double _currentHeading = 0.0;
  double _totalDistance = 0.0;

  double get currentSpeed => _currentSpeed;
  double get currentHeading => _currentHeading;
  double get totalDistance => _totalDistance;
  Position? get lastPosition => _lastPosition;

  Future<bool> requestPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      return requested == LocationPermission.whileInUse ||
          requested == LocationPermission.always;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  void startTracking({
    void Function(double speed, double heading)? onSpeedUpdate,
    void Function(Position position)? onPositionUpdate,
    void Function(String error)? onError,
  }) {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      timeLimit: null,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (Position position) {
        _processPosition(position);
        onSpeedUpdate?.call(_currentSpeed, _currentHeading);
        onPositionUpdate?.call(position);
      },
      onError: (Object error) {
        onError?.call(error.toString());
      },
    );
  }

  void _processPosition(Position position) {
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      _totalDistance += distance;
    }

    _currentHeading = position.heading;
    _lastPosition = position;

    if (position.speed >= 0) {
      _currentSpeed = position.speed * 3.6;
    } else {
      _currentSpeed = 0;
    }
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  double calculateDistanceTo(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  void resetTotalDistance() {
    _totalDistance = 0.0;
  }

  void dispose() {
    stopTracking();
  }
}
