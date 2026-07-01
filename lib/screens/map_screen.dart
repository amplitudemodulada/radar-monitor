import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/speed_provider.dart';
import '../providers/radar_provider.dart';
import '../providers/alert_provider.dart';
import '../models/radar_point.dart';
import '../utils/constants.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Radares'),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<RadarProvider>(
            builder: (context, radar, _) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${radar.totalRadars} radares',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer3<SpeedProvider, RadarProvider, AlertProvider>(
        builder: (context, speed, radar, alert, _) {
          final position = speed.currentPosition;

          if (position == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.gps_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Aguardando sinal GPS...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          final userLocation = LatLng(position.latitude, position.longitude);
          final allRadars = radar.allRadars;

          return FlutterMap(
            options: MapOptions(
              initialCenter: userLocation,
              initialZoom: 15.0,
              minZoom: 10,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.tilesUrl,
                userAgentPackageName: 'com.radarmonitor.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.navigation,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                  ),
                  ...allRadars.where((r) => r.ativo).map(
                    (radarPoint) => _buildRadarMarker(radarPoint),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  if (speed.currentPosition != null)
                    Polyline(
                      points: [userLocation],
                      color: Colors.blue.withOpacity(0.5),
                      strokeWidth: 3,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Marker _buildRadarMarker(RadarPoint radar) {
    Color markerColor;
    String label;

    switch (radar.tipo) {
      case 'fixo':
        markerColor = Colors.red;
        label = '${radar.velocidadeMaxima}';
        break;
      case 'movel':
        markerColor = Colors.orange;
        label = 'M${radar.velocidadeMaxima}';
        break;
      case 'pedagio':
        markerColor = Colors.purple;
        label = 'P${radar.velocidadeMaxima}';
        break;
      default:
        markerColor = Colors.red;
        label = '${radar.velocidadeMaxima}';
    }

    return Marker(
      point: LatLng(radar.latitude, radar.longitude),
      width: 80,
      height: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: markerColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Icon(Icons.radar, color: markerColor, size: 28),
        ],
      ),
    );
  }
}
