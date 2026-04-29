import 'package:flutter/foundation.dart';
import '../../data/models/parking_sensor.dart';
import '../../domain/usecases/get_parking_data_usecase.dart';
import '../../domain/usecases/clear_cache_usecase.dart';

enum DataState { loading, loaded, error, empty }
enum DataSource { online, cached, none }

class ParkingProvider with ChangeNotifier {
  final GetParkingDataUseCase getParkingDataUseCase;
  final ClearCacheUseCase clearCacheUseCase;
  
  ParkingProvider({
    required this.getParkingDataUseCase,
    required this.clearCacheUseCase,
  });

  List<ParkingSensor> _sensors = [];
  DataState _state = DataState.empty;
  DataSource _source = DataSource.none;
  String _errorMessage = '';

  List<ParkingSensor> get sensors => _sensors;
  DataState get state => _state;
  DataSource get source => _source;
  String get errorMessage => _errorMessage;

  Future<void> fetchParkingData() async {
    _state = DataState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await getParkingDataUseCase.execute();
      final List<ParkingSensor> data = result['data'];
      final String sourceStr = result['source'];

      _sensors = data;
      _source = sourceStr == 'online' ? DataSource.online : DataSource.cached;

      if (_sensors.isEmpty) {
        _state = DataState.empty;
      } else {
        _state = DataState.loaded;
      }
    } catch (e) {
      _state = DataState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _source = DataSource.none;
    }
    notifyListeners();
  }

  Future<void> clearCache() async {
    await clearCacheUseCase.execute();
    if (_source == DataSource.cached) {
      _sensors = [];
      _state = DataState.empty;
      _source = DataSource.none;
      notifyListeners();
    }
  }
}
