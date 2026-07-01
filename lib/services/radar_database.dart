import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import '../models/radar_point.dart';
import '../utils/constants.dart';

class RadarDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE radares (
        id INTEGER PRIMARY KEY,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        tipo TEXT NOT NULL,
        velocidade_maxima INTEGER NOT NULL,
        direcao TEXT NOT NULL,
        ativo INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> loadInitialData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM radares'),
    );

    if (count != null && count > 0) return;

    final jsonString = await rootBundle.loadString(AppConstants.radarAssetsPath);
    final List<dynamic> jsonList = json.decode(jsonString);

    final batch = db.batch();
    for (final json in jsonList) {
      final radar = RadarPoint.fromJson(json as Map<String, dynamic>);
      batch.insert('radares', radar.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<RadarPoint>> getRadarsInRadius(
      double lat, double lon, double radiusMeters) async {
    final db = await database;

    final latDelta = radiusMeters / 111320.0;
    final lonDelta = radiusMeters / (111320.0 * _cos(lat));

    final radars = await db.query(
      'radares',
      where:
          'latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ? AND ativo = 1',
      whereArgs: [
        lat - latDelta,
        lat + latDelta,
        lon - lonDelta,
        lon + lonDelta,
      ],
    );

    final result = <RadarPoint>[];
    for (final map in maps) {
      final radar = RadarPoint.fromMap(map);
      final distance = radar.distanceTo(lat, lon);
      if (distance <= radiusMeters) {
        result.add(radar);
      }
    }

    result.sort((a, b) =>
        a.distanceTo(lat, lon).compareTo(b.distanceTo(lat, lon)));
    return result;
  }

  Future<List<RadarPoint>> getAllRadars() async {
    final db = await database;
    final maps = await db.query('radares');
    return maps.map((map) => RadarPoint.fromMap(map)).toList();
  }

  Future<int> insertRadar(RadarPoint radar) async {
    final db = await database;
    return await db.insert('radares', radar.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertRadars(List<RadarPoint> radars) async {
    final db = await database;
    final batch = db.batch();
    for (final radar in radars) {
      batch.insert('radares', radar.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<int> updateRadar(RadarPoint radar) async {
    final db = await database;
    return await db.update(
      'radares',
      radar.toMap(),
      where: 'id = ?',
      whereArgs: [radar.id],
    );
  }

  Future<int> deleteRadar(int id) async {
    final db = await database;
    return await db.delete('radares', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getRadarCount() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM radares'),
    );
    return result ?? 0;
  }

  double _cos(double degrees) {
    final rad = degrees * 3.141592653589793 / 180;
    return _cosApprox(rad);
  }

  double _cosApprox(double x) {
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
