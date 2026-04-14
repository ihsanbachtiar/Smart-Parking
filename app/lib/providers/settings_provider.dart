import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences prefs;

  SettingsProvider(this.prefs) {
    _loadSettings();
  }

  bool _isDarkMode = false;
  String _username = 'Admin IoT';

  bool get isDarkMode => _isDarkMode;
  String get username => _username;

  void _loadSettings() {
    _isDarkMode = prefs.getBool('THEME_MODE') ?? false;
    _username = prefs.getString('USERNAME') ?? 'Admin IoT';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await prefs.setBool('THEME_MODE', _isDarkMode);
    notifyListeners();
  }

  Future<void> setUsername(String name) async {
    _username = name;
    await prefs.setString('USERNAME', name);
    notifyListeners();
  }
}
