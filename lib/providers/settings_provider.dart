// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadSettings();
  }

  // Muat pengaturan dari SharedPreferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Muat Tema
    final theme = prefs.getString('theme') ?? 'system';
    switch (theme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    
    // Muat Bahasa
    final languageCode = prefs.getString('language') ?? 'en';
    _locale = Locale(languageCode);

    notifyListeners();
  }

  // Perbarui Tema
  void updateTheme(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', newThemeMode.name);
  }

  // Perbarui Bahasa
  void updateLanguage(Locale newLocale) async {
    if (newLocale == _locale) return;
    _locale = newLocale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', newLocale.languageCode);
  }
}