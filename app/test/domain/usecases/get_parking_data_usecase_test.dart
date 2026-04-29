import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:smart_parking_app/domain/usecases/get_parking_data_usecase.dart';
import 'package:smart_parking_app/domain/repositories/parking_repository.dart';
import 'package:smart_parking_app/data/models/parking_sensor.dart';

// Import file mock yang akan otomatis di-generate nanti oleh build_runner
import 'get_parking_data_usecase_test.mocks.dart';

// Anotasi Mockito untuk men-generate class MockParkingRepository
@GenerateMocks([ParkingRepository])
void main() {
  late GetParkingDataUseCase usecase;
  late MockParkingRepository mockRepository;

  setUp(() {
    mockRepository = MockParkingRepository();
    usecase = GetParkingDataUseCase(mockRepository);
  });

  // Contoh data dummy untuk tes
  final tSensorList = [
    ParkingSensor(
      id: '1',
      deviceName: 'Sensor A',
      description: 'Test Sensor',
      availableSlots: 5,
      occupiedSlots: 10,
      isActive: true,
      updatedAt: DateTime.now(),
    )
  ];

  group('GetParkingDataUseCase Tests', () {
    // 1. SUCCESS CASE (Modul 9: Bagian 4)
    test('Harus mengembalikan Map data online saat repository sukses', () async {
      // arrange
      when(mockRepository.getParkingData()).thenAnswer((_) async => tSensorList);

      // act
      final result = await usecase.execute();

      // assert
      expect(result['source'], 'online');
      expect(result['data'], tSensorList);
      verify(mockRepository.getParkingData());
      verifyNoMoreInteractions(mockRepository);
    });

    // 2. ERROR CASE (Modul 9: Bagian 5)
    test('Harus melempar Exception jika online gagal dan cache kosong', () async {
      // arrange
      when(mockRepository.getParkingData()).thenThrow(Exception('Server Down'));
      when(mockRepository.getCachedParkingData()).thenThrow(Exception('No Cache'));

      // act & assert
      // Pengujian error menggunakan throwsException / format lambda (() async => ...)
      expect(
        () async => await usecase.execute(),
        throwsException,
      );
      verify(mockRepository.getParkingData());
      verify(mockRepository.getCachedParkingData());
    });

    // 3. EDGE CASE (Modul 9: Bagian 6)
    test('Harus mengembalikan list kosong ketika tidak ada data dari sensor', () async {
      // arrange
      when(mockRepository.getParkingData()).thenAnswer((_) async => <ParkingSensor>[]);

      // act
      final result = await usecase.execute();

      // assert
      final List<ParkingSensor> resultData = result['data'];
      expect(resultData.isEmpty, true);
    });
  });
}
