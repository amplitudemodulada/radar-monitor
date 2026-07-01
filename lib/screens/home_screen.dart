import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speed_provider.dart';
import '../providers/radar_provider.dart';
import '../providers/alert_provider.dart';
import '../widgets/speedometer.dart';
import '../widgets/digital_speed.dart';
import '../widgets/radar_alert_overlay.dart';
import '../widgets/gps_indicator.dart';
import '../utils/constants.dart';
import 'map_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final speedProvider = context.read<SpeedProvider>();
    final radarProvider = context.read<RadarProvider>();
    final alertProvider = context.read<AlertProvider>();

    await radarProvider.initialize();
    await alertProvider.loadConfig();

    final gpsReady = await speedProvider.initialize();
    if (gpsReady && mounted) {
      speedProvider.startTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Consumer3<SpeedProvider, RadarProvider, AlertProvider>(
        builder: (context, speed, radar, alert, _) {
          _checkAlerts(speed, radar, alert);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade900,
                  Colors.grey.shade850,
                  Colors.black87,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  _buildMainContent(speed, radar, alert, theme),
                  Positioned(
                    top: 8,
                    left: 16,
                    child: GpsIndicator(status: speed.gpsStatus),
                  ),
                  Positioned(
                    top: 8,
                    right: 16,
                    child: Row(
                      children: [
                        _buildIconButton(
                          Icons.map_outlined,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          Icons.settings_outlined,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (alert.isAlerting)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: RadarAlertOverlay(
                        alertType: alert.currentAlert,
                        radar: alert.alertingRadar,
                        currentSpeed: speed.speed,
                        onDismiss: alert.dismissAlert,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(
    SpeedProvider speed,
    RadarProvider radar,
    AlertProvider alert,
    ThemeData theme,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Speedometer(
              speed: speed.speed,
              maxSpeed: AppConstants.maxSpeedKmh,
              size: MediaQuery.of(context).size.width * 0.75,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DigitalSpeed(
                speed: speed.speed,
                heading: speed.heading,
                satellites: speed.satellites,
              ),
            ),
            const SizedBox(height: 16),
            if (radar.closestRadar != null)
              _buildNearestRadarInfo(radar.closestRadar!, speed.speed),
            const SizedBox(height: 12),
            _buildQuickStats(speed),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildNearestRadarInfo(radar, double currentSpeed) {
    final isOverLimit = currentSpeed > radar.velocidadeMaxima;
    return Card(
      color: isOverLimit
          ? Colors.red.shade900.withOpacity(0.6)
          : Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.radar,
              color: isOverLimit ? Colors.red : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Radar: ${radar.velocidadeMaxima} km/h',
                  style: TextStyle(
                    color: isOverLimit ? Colors.red : Colors.orange.shade300,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isOverLimit ? 'ACIMA DO LIMITE!' : 'Dentro do limite',
                  style: TextStyle(
                    color: isOverLimit ? Colors.red : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(SpeedProvider speed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            icon: Icons.speed,
            label: 'Máxima',
            value: '${speed.maxSpeed.toStringAsFixed(0)} km/h',
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.straighten,
            label: 'Distância',
            value: '${(speed.distance / 1000).toStringAsFixed(1)} km',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 22),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }

  void _checkAlerts(
    SpeedProvider speed,
    RadarProvider radar,
    AlertProvider alert,
  ) {
    if (speed.currentPosition != null) {
      final pos = speed.currentPosition!;

      radar.updateRadarsNearby(
        pos.latitude,
        pos.longitude,
        AppConstants.radarAlertDistance,
      );

      final closest = radar.closestRadar;
      if (closest != null) {
        final distance = closest.distanceTo(pos.latitude, pos.longitude);
        if (distance <= AppConstants.radarAlertDistance) {
          alert.checkRadarAlert(
            radar.nearbyRadars,
            speed.speed,
            pos.latitude,
            pos.longitude,
          );
          alert.checkSpeedAlert(speed.speed, closest.velocidadeMaxima);
        }
      }
    }
  }
}
