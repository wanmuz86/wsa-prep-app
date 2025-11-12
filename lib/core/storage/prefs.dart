import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static const String _keyJacketColor = 'jacket_color';
  static const String _defaultColor = '4280391411'; // Default blue color value

  String _jacketColor = _defaultColor;

  String get jacketColor => _jacketColor;

  PreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _jacketColor = prefs.getString(_keyJacketColor) ?? _defaultColor;
    notifyListeners();
  }

  Future<void> setJacketColor(String colorValue) async {
    _jacketColor = colorValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJacketColor, colorValue);
    notifyListeners();
  }
}

