import 'package:flutter/material.dart';
import '../models/radar_point.dart';
import '../providers/alert_provider.dart';

class RadarAlertOverlay extends StatelessWidget {
  final AlertType alertType;
  final RadarPoint? radar;
  final double currentSpeed;
  final VoidCallback onDismiss;

  const RadarAlertOverlay({
    super.key,
    required this.alertType,
    this.radar,
    required this.currentSpeed,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (alertType == AlertType.none) return const SizedBox.shrink();

    final isRadar = alertType == AlertType.radarProximo;

    return Material(
      color: Colors.transparent,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: isRadar
                  ? [Colors.orange.shade800, Colors.red.shade800]
                  : [Colors.red.shade700, Colors.red.shade900],
            ),
            boxShadow: [
              BoxShadow(
                color: (isRadar ? Colors.orange : Colors.red)
                    .withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onDismiss,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          isRadar ? Icons.radar : Icons.speed,
                          color: Colors.white,
                          size: 32,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: onDismiss,
                        ),
                      ],
                    ),
                    Icon(
                      isRadar ? Icons.warning_rounded : Icons.dangerous,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isRadar ? 'RADAR PRÓXIMO!' : 'EXCESSO DE VELOCIDADE!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isRadar && radar != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${radar!.velocidadeMaxima} km/h',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Velocidade máxima permitida',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          radar!.tipo == 'fixo' ? 'Radar Fixo' : 'Radar Móvel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    if (!isRadar) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${currentSpeed.toStringAsFixed(0)} km/h',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Reduza a velocidade!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
