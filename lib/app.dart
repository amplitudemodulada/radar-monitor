import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

class RadarMonitorApp extends StatelessWidget {
  const RadarMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF1A73E8),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade900,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF1A73E8);
            }
            return Colors.grey.shade400;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF1A73E8).withOpacity(0.5);
            }
            return Colors.grey.shade700;
          }),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF1A73E8),
          inactiveTrackColor: Colors.grey.shade700,
          thumbColor: const Color(0xFF1A73E8),
          overlayColor: const Color(0xFF1A73E8).withOpacity(0.2),
          valueIndicatorColor: const Color(0xFF1A73E8),
          valueIndicatorTextStyle: const TextStyle(color: Colors.white),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
