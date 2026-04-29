import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/services/parking_api_service.dart';
import 'data/repositories/parking_repository_impl.dart';
import 'domain/usecases/get_parking_data_usecase.dart';
import 'domain/usecases/clear_cache_usecase.dart';

import 'presentation/providers/parking_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Dependecy Injection Setup (Clean Architecture)
  final apiService = ParkingApiService(prefs: prefs);
  final repository = ParkingRepositoryImpl(apiService: apiService);
  final getParkingDataUseCase = GetParkingDataUseCase(repository);
  final clearCacheUseCase = ClearCacheUseCase(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ParkingProvider(
            getParkingDataUseCase: getParkingDataUseCase,
            clearCacheUseCase: clearCacheUseCase,
          ),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
      ],
      child: const SmartParkingApp(),
    ),
  );
}

class SmartParkingApp extends StatelessWidget {
  const SmartParkingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Smart Parking IoT',
          debugShowCheckedModeBanner: false,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            primaryColor: const Color(0xFF0D47A1), // Modern Blue Theme
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color(0xFF0D47A1),
              secondary: const Color(0xFF1976D2),
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            fontFamily: 'Inter',
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: const Color(0xFF90CAF9),
            colorScheme: const ColorScheme.dark().copyWith(
              primary: const Color(0xFF90CAF9),
              secondary: const Color(0xFF64B5F6),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
