import 'package:flutter/material.dart';
import 'service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._settingsService);
  
  final SettingsService _settingsService;
  
  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }
}