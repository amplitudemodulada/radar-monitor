class AppConstants {
  AppConstants._();

  static const String appName = 'Radar Monitor';
  static const String dbName = 'radar_monitor.db';
  static const int dbVersion = 1;
  static const double radarAlertDistance = 500.0;
  static const double criticalRadarDistance = 200.0;
  static const double speedUpdateInterval = 1.0;
  static const double gpsAccuracyMin = 10.0;
  static const double maxSpeedKmh = 260.0;
  static const double speedWarningThreshold = 1.1;
  static const String radarApiUrl = 'https://api.radares.org/v1/radars';
  static const String tilesUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String attribution = '© OpenStreetMap contributors';
  static const String radarAssetsPath = 'assets/data/radares.json';
}
