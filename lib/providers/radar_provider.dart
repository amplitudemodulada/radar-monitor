import 'package:flutter/foundation.dart';
import '../models/radar_point.dart';
import '../services/radar_database.dart';
import '../services/radar_update_service.dart';

class RadarProvider extends ChangeNotifier {
  final RadarDatabase _database = RadarDatabase();
  late final RadarUpdateService _updateService;

  List<RadarPoint> _nearbyRadars = [];
  List<RadarPoint> _allRadars = [];
  RadarPoint? _closestRadar;
  bool _isLoading = false;
  String? _errorMessage;
  int _totalRadars = 0;

  RadarProvider() {
    _updateService = RadarUpdateService(_database);
  }

  List<RadarPoint> get nearbyRadars => _nearbyRadars;
  List<RadarPoint> get allRadars => _allRadars;
  RadarPoint? get closestRadar => _closestRadar;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalRadars => _totalRadars;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _database.loadInitialData();
      _allRadars = await _database.getAllRadars();
      _totalRadars = _allRadars.length;
    } catch (e) {
      _errorMessage = 'Erro ao carregar dados: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateRadarsNearby(double lat, double lon, double radius) async {
    try {
      _nearbyRadars = await _database.getRadarsInRadius(lat, lon, radius);
      _closestRadar = _nearbyRadars.isNotEmpty ? _nearbyRadars.first : null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao buscar radares: $e';
      notifyListeners();
    }
  }

  Future<UpdateResult> updateFromApi() async {
    _isLoading = true;
    notifyListeners();

    final result = await _updateService.updateFromApi();

    if (result.success) {
      _allRadars = await _database.getAllRadars();
      _totalRadars = _allRadars.length;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<UpdateResult> getLocalCount() async {
    return await _updateService.getLocalCount();
  }

  double distanceToClosest(double lat, double lon) {
    if (_closestRadar == null) return double.infinity;
    return _closestRadar!.distanceTo(lat, lon);
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }
}
