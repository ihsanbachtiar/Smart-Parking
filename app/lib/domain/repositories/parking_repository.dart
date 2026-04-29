import '../../data/models/parking_sensor.dart';

// Definisi Interface/Contract untuk Repository
abstract class ParkingRepository {
  Future<List<ParkingSensor>> getParkingData();
  Future<List<ParkingSensor>> getCachedParkingData();
  Future<void> clearCache();
}
