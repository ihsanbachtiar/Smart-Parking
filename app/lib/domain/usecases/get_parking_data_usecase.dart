import '../../data/models/parking_sensor.dart';
import '../repositories/parking_repository.dart';

class GetParkingDataUseCase {
  final ParkingRepository repository;

  GetParkingDataUseCase(this.repository);

  // Return a Map string as Source (Online/Cached/None) and the data. 
  // We can also return a custom Result object, but to keep it simple:
  Future<Map<String, dynamic>> execute() async {
    try {
      final onlineData = await repository.getParkingData();
      return {
        'source': 'online',
        'data': onlineData,
      };
    } catch (e) {
      // Jika gagal, fallback ke cache
      try {
        final cachedData = await repository.getCachedParkingData();
        return {
          'source': 'cached',
          'data': cachedData,
        };
      } catch (cacheError) {
        throw Exception('Tidak dapat terhubung ke server dan tidak ada data cache.');
      }
    }
  }
}
