import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../providers/speed_provider.dart';
import '../providers/radar_provider.dart';
import '../models/alert_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AlertProvider>(
        builder: (context, alertProvider, _) {
          final config = alertProvider.config;
          return Container(
            color: Colors.grey.shade100,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('Alertas de Radar'),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.radar,
                        title: 'Alerta de radar próximo',
                        subtitle: 'Notificar quando houver radar nas proximidades',
                        value: config.alertaRadarProximo,
                        onChanged: (v) =>
                            alertProvider.updateConfigField('alertaRadarProximo', v),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildSwitchTile(
                        icon: Icons.speed,
                        title: 'Alerta de excesso de velocidade',
                        subtitle: 'Notificar ao ultrapassar o limite da via',
                        value: config.alertaExcessoVelocidade,
                        onChanged: (v) => alertProvider
                            .updateConfigField('alertaExcessoVelocidade', v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Distância de Alerta'),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Distância para alerta',
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              '${config.distanciaAlerta.toInt()} m',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: config.distanciaAlerta,
                          min: 100,
                          max: 2000,
                          divisions: 19,
                          label: '${config.distanciaAlerta.toInt()} m',
                          onChanged: (v) => alertProvider
                              .updateConfigField('distanciaAlerta', v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('100m', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            Text('2000m', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Notificações'),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.volume_up,
                        title: 'Som de alerta',
                        subtitle: 'Tocar som ao detectar radar ou excesso',
                        value: config.somAtivo,
                        onChanged: (v) =>
                            alertProvider.updateConfigField('somAtivo', v),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildSwitchTile(
                        icon: Icons.vibration,
                        title: 'Vibração',
                        subtitle: 'Vibrar ao emitir alerta',
                        value: config.vibracaoAtiva,
                        onChanged: (v) =>
                            alertProvider.updateConfigField('vibracaoAtiva', v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Intensidade'),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.volume_down, size: 20),
                            Expanded(
                              child: Slider(
                                value: config.intensidadeAlerta,
                                min: 0.1,
                                max: 1.0,
                                divisions: 9,
                                label: '${(config.intensidadeAlerta * 100).toInt()}%',
                                onChanged: (v) => alertProvider
                                    .updateConfigField('intensidadeAlerta', v),
                              ),
                            ),
                            const Icon(Icons.volume_up, size: 20),
                          ],
                        ),
                        Center(
                          child: Text(
                            '${(config.intensidadeAlerta * 100).toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Base de Radares'),
                const SizedBox(height: 8),
                Consumer<RadarProvider>(
                  builder: (context, radarProvider, _) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.storage),
                            title: const Text('Radares na base local'),
                            trailing: Text(
                              '${radarProvider.totalRadars}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.update),
                            title: const Text('Atualizar radares online'),
                            subtitle: const Text('Baixar dados atualizados'),
                            trailing: radarProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.download),
                            onTap: () => _updateRadars(context, radarProvider),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }

  Future<void> _updateRadars(BuildContext context, RadarProvider radarProvider) async {
    final result = await radarProvider.updateFromApi();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
