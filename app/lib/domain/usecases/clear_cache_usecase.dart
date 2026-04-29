import '../repositories/parking_repository.dart';

class ClearCacheUseCase {
  final ParkingRepository repository;

  ClearCacheUseCase(this.repository);

  Future<void> execute() async {
    await repository.clearCache();
  }
}
