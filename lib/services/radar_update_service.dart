import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/radar_point.dart';
import '../utils/constants.dart';
import 'radar_database.dart';

class RadarUpdateService {
  final RadarDatabase _database;

  RadarUpdateService(this._database);

  Future<UpdateResult> updateFromApi() async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.radarApiUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final radars = data
            .map((json) => RadarPoint.fromJson(json as Map<String, dynamic>))
            .toList();

        await _database.insertRadars(radars);
        return UpdateResult(
          success: true,
          count: radars.length,
          message: '${radars.length} radares atualizados com sucesso.',
        );
      } else {
        return UpdateResult(
          success: false,
          count: 0,
          message: 'Erro ao conectar: ${response.statusCode}',
        );
      }
    } on Exception catch (e) {
      return UpdateResult(
        success: false,
        count: 0,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<UpdateResult> getLocalCount() async {
    final count = await _database.getRadarCount();
    return UpdateResult(
      success: true,
      count: count,
      message: '$count radares na base local.',
    );
  }
}

class UpdateResult {
  final bool success;
  final int count;
  final String message;

  UpdateResult({
    required this.success,
    required this.count,
    required this.message,
  });
}
