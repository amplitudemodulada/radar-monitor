import 'package:flutter/material.dart';

class DigitalSpeed extends StatelessWidget {
  final double speed;
  final double maxSpeed;
  final double heading;
  final int satellites;

  const DigitalSpeed({
    super.key,
    required this.speed,
    this.maxSpeed = 0,
    this.heading = 0,
    this.satellites = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(
              icon: Icons.speed,
              label: 'Velocidade',
              value: '${speed.toStringAsFixed(0)}',
              unit: 'km/h',
              color: _getSpeedColor(),
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildStat(
              icon: Icons.explore,
              label: 'Direção',
              value: '${heading.toStringAsFixed(0)}°',
              unit: _getHeadingText(heading),
              color: theme.colorScheme.secondary,
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildStat(
              icon: Icons.satellite_alt,
              label: 'Satélites',
              value: '$satellites',
              unit: 'conectados',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Color _getSpeedColor() {
    if (maxSpeed <= 0) return Colors.green;
    final fraction = speed / maxSpeed;
    if (fraction < 0.5) return Colors.green;
    if (fraction < 0.75) return Colors.orange;
    if (fraction < 0.9) return Colors.deepOrange;
    return Colors.red;
  }

  String _getHeadingText(double degrees) {
    if (degrees < 22.5 || degrees >= 337.5) return 'N';
    if (degrees < 67.5) return 'NE';
    if (degrees < 112.5) return 'L';
    if (degrees < 157.5) return 'SE';
    if (degrees < 202.5) return 'S';
    if (degrees < 247.5) return 'SO';
    if (degrees < 292.5) return 'O';
    return 'NO';
  }
}
