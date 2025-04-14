
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ScrollProvider with ChangeNotifier {
  bool _isAutoScrollEnabled = false;
  double _scrollSpeed = 2.0; // pixels per frame

  bool get isAutoScrollEnabled => _isAutoScrollEnabled;
  double get scrollSpeed => _scrollSpeed;

  ScrollProvider() {
    _loadScrollPreferences();
  }

  Future<void> _loadScrollPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _scrollSpeed = prefs.getDouble('scrollSpeed') ?? 2.0;
    notifyListeners();
  }

  void toggleAutoScroll() {
    _isAutoScrollEnabled = !_isAutoScrollEnabled;
    notifyListeners();
  }

  void setScrollSpeed(double speed) async {
    _scrollSpeed = speed;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scrollSpeed', speed);

    notifyListeners();
  }
}