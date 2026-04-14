import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_sensor.dart';

enum DataState { loading, loaded, error, empty }
enum DataSource { online, cached, none }

class ParkingProvider with ChangeNotifier {
  final SharedPreferences prefs;
  
  ParkingProvider(this.prefs);

  List<ParkingSensor> _sensors = [];
  DataState _state = DataState.empty;
  DataSource _source = DataSource.none;
  String _errorMessage = '';

  List<ParkingSensor> get sensors => _sensors;
  DataState get state => _state;
  DataSource get source => _source;
  String get errorMessage => _errorMessage;

  // Endpoint Mock API Express.js 
  // Gunakan 10.0.2.2 jika di Android Emulator, atau localhost jika web/iOS simulator
  final String apiUrl = 'http://localhost:3500/api/parking';
  final String cacheKey = 'CACHED_PARKING_DATA';

  Future<void> fetchParkingData() async {
    _state = DataState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        // Berhasil Online
        final List<dynamic> data = json.decode(response.body);
        _sensors = data.map((json) => ParkingSensor.fromJson(json)).toList();
        
        // Simpan ke Cache
        await prefs.setString(cacheKey, response.body);
        
        if (_sensors.isEmpty) {
          _state = DataState.empty;
        } else {
          _state = DataState.loaded;
        }
        _source = DataSource.online;
      } else {
        throw Exception('Failed to load online data');
      }
    } catch (e) {
      // Gagal HTTP, coba load dari local cache
      final String? cachedDataString = prefs.getString(cacheKey);
      if (cachedDataString != null && cachedDataString.isNotEmpty) {
        final List<dynamic> data = json.decode(cachedDataString);
        _sensors = data.map((json) => ParkingSensor.fromJson(json)).toList();
        _state = DataState.loaded;
        _source = DataSource.cached; // Menandakan bahwa data ini Cache
      } else {
        _state = DataState.error;
        _errorMessage = 'Tidak dapat terhubung ke server dan tidak ada data cache.';
        _source = DataSource.none;
      }
    }
    notifyListeners();
  }
  Future<void> clearCache() async {
    await prefs.remove(cacheKey);
    // Jika sedang dalam tampilan cache, mungkin kita ingin membersihkan layar
    if (_source == DataSource.cached) {
      _sensors = [];
      _state = DataState.empty;
      _source = DataSource.none;
      notifyListeners();
    }
  }
}
