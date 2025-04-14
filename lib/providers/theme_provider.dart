
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isSepia = false;

  ThemeMode get themeMode => _themeMode;
  bool get isSepia => _isSepia;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeValue = prefs.getString('themeMode') ?? 'system';
    _themeMode = _getThemeMode(themeModeValue);
    _isSepia = prefs.getBool('isSepia') ?? false;
    notifyListeners();
  }

  ThemeMode _getThemeMode(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String value = 'system';

    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';

    await prefs.setString('themeMode', value);
  }

  void toggleSepia() async {
    _isSepia = !_isSepia;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSepia', _isSepia);
  }

  ThemeData get lightTheme {
    if (_isSepia) {
      return ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Color(0xFFF5ECD7),
        cardColor: Color(0xFFEEE0C0),
        canvasColor: Color(0xFFF5ECD7),
        brightness: Brightness.light,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF5C4B26)),
          bodyMedium: TextStyle(color: Color(0xFF5C4B26)),
        ),
      );
    }

    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF121212),
      cardColor: Color(0xFF1E1E1E),
    );
  }
}