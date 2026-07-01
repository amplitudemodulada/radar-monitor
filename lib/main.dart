import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/speed_provider.dart';
import 'providers/radar_provider.dart';
import 'providers/alert_provider.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeedProvider()),
        ChangeNotifierProvider(create: (_) => RadarProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
      ],
      child: const RadarMonitorApp(),
    ),
  );
}
