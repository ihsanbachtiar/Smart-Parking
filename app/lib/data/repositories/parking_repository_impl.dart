import '../../domain/repositories/parking_repository.dart';
import '../models/parking_sensor.dart';
import '../services/parking_api_service.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingApiService apiService;

  ParkingRepositoryImpl({required this.apiService});

  @override
  Future<List<ParkingSensor>> getParkingData() async {
    // Repository bertugas memanggil service
    return await apiService.fetchParkingDataOnline();
  }

  @override
  Future<List<ParkingSensor>> getCachedParkingData() async {
    return await apiService.fetchParkingDataCached();
  }

  @override
  Future<void> clearCache() async {
    return await apiService.clearCacheData();
  }
}
