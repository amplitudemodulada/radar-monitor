import 'package:flutter/material.dart';
import '../providers/speed_provider.dart';

class GpsIndicator extends StatelessWidget {
  final GpsStatus status;

  const GpsIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getColor().withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getColor().withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getText(),
            style: TextStyle(
              color: _getColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case GpsStatus.connected:
        return const Color(0xFF4CAF50);
      case GpsStatus.searching:
        return const Color(0xFFFFC107);
      case GpsStatus.disconnected:
        return const Color(0xFFF44336);
    }
  }

  String _getText() {
    switch (status) {
      case GpsStatus.connected:
        return 'GPS OK';
      case GpsStatus.searching:
        return 'Buscando GPS...';
      case GpsStatus.disconnected:
        return 'GPS Desconectado';
    }
  }
}
