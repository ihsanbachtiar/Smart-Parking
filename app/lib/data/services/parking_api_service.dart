import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_sensor.dart';

class ParkingApiService {
  final SharedPreferences prefs;
  final String apiUrl = 'http://localhost:3500/api/parking';
  final String cacheKey = 'CACHED_PARKING_DATA';

  ParkingApiService({required this.prefs});

  Future<List<ParkingSensor>> fetchParkingDataOnline() async {
    final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final sensors = data.map((json) => ParkingSensor.fromJson(json)).toList();
      
      // Save to cache
      await prefs.setString(cacheKey, response.body);
      
      return sensors;
    } else {
      throw Exception('Failed to load online data');
    }
  }

  Future<List<ParkingSensor>> fetchParkingDataCached() async {
    final String? cachedDataString = prefs.getString(cacheKey);
    if (cachedDataString != null && cachedDataString.isNotEmpty) {
      final List<dynamic> data = json.decode(cachedDataString);
      return data.map((json) => ParkingSensor.fromJson(json)).toList();
    } else {
      throw Exception('Tidak ada data cache tersedia.');
    }
  }

  Future<void> clearCacheData() async {
    await prefs.remove(cacheKey);
  }
}
